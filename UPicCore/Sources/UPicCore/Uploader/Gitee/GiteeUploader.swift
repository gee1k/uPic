//
//  Gitee.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON

private struct ReseponseModel: HandyJSON {
    var content: ReseponseContentModel?
    var message: String?
    var documentation_url: String?
}

private struct ReseponseContentModel: HandyJSON {
    var name: String?
    var path: String?
    var sha: String?
    var size: Int?
    var url: String?
    var html_url: String?
    var git_url: String?
    var download_url: String?
}

public class GiteeUploader {
    
    internal static let allowExtensions: [String] = []
   
    private static func getRequestConfig(_ config: GiteeHostConfig, saveKey: String, data: Data) -> RequestConfig {
        
        var parameters = Parameters()
        parameters["access_token"] = config.token
        parameters["branch"] = config.branch
        parameters["path"] = saveKey.urlEncoded()
        parameters["content"] = data.base64EncodedString()
        parameters["message"] = "⬆ Upload by uPic \n👉❤️ Powered by https://github.com/gee1k/uPic ❤️👈"
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/json"))
        headers.add(HTTPHeader.defaultUserAgent)
        
        var requestConfig = RequestConfig()
        requestConfig.url = "https://gitee.com/api/v5/repos/\(config.owner!)/\(config.repo!)/contents/\(saveKey.urlEncoded())"
        requestConfig.method = .post
        requestConfig.headers = headers
        requestConfig.parameters = parameters
        requestConfig.encoding = JSONEncoding.default
        
        return requestConfig
    }
    
    internal static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.getConfig(GiteeHostConfig.self), config.isValid() else {
            ctx._uploadFail(.invalidConfig)
            return
        }
        
        let domain = config.domain
        let saveKey = FormatUtil.parseSaveKeyPath(config.saveKeyPath, filename)
        
        let requestConfig = self.getRequestConfig(config, saveKey: saveKey, data: data)
        
        ctx.requester.request(requestConfig).validate().uploadProgress{ progress in
            ctx._uploadProgress(progress.fractionCompleted)
        }.responseString{ response in
            switch response.result {
            case .success(let value):
                guard let model = ReseponseModel.deserialize(from: value) else {
                    ctx._uploadFail(.invalidResponse, detailError: response.data?.toString())
                    return
                }
                if let message = model.message {
                    ctx._uploadFail(message, detailError: response.data?.toString())
                    return
                }
                
                if let downloadUrl = model.content?.download_url?.urlDecoded(), domain.isEmpty {
                    ctx._uploadComplete(downloadUrl)
                } else {
                    ctx._uploadComplete("\(domain)/\(saveKey)")
                }
                
            case .failure(let error):
                var errorMessage = error.localizedDescription
                if let resData = response.data, let resString = String(data: resData, encoding: .utf8),
                    let model = ReseponseModel.deserialize(from: resString), let message = model.message {
                    errorMessage = message
                }
                ctx._uploadFail(errorMessage, detailError: response.data?.toString())
            }
        }
    }
}
