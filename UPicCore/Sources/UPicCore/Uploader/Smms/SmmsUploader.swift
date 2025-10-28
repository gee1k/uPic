//
//  Smms.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON

private struct ReseponseModel: HandyJSON {
    var data: ReseponseDataModel?
    var success: Bool!
    var code: String?
    var images: String?
    var message: String?
}

private struct ReseponseDataModel: HandyJSON {
    var filename: String?
    var storename: String?
    var path: String?
    var url: String?
    var delete: String?
}

public class SmmsUploader {
    
    internal static let allowExtensions: [String] = ["jpeg", "jpg", "png", "gif", "bmp"]
    
    // https://doc.sm.ms/
    static let url = "https://smms.app/api/v2/upload"
   
    private static func getRequestConfig(_ config: SmmsHostConfig, filename: String, data: Data) -> RequestConfig {
        
        var headers: HTTPHeaders = HTTPHeaders()
        headers.add(HTTPHeader.contentType("multipart/form-data"))
        headers.add(name: "referer", value: "https://smms.app/")
        headers.add(name: "origin", value: "https://smms.app")
        headers.add(HTTPHeader.authorization(config.token!))
       
        let multipartFormData = MultipartFormData()
        multipartFormData.append(data, withName: "smfile", fileName: filename, mimeType: filename.mimeType)
        
        var requestConfig = RequestConfig()
        requestConfig.url = url
        requestConfig.method = .post
        requestConfig.headers = headers
        requestConfig.multipartFormData = multipartFormData
        
        return requestConfig
    }
    
    internal static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.data as? SmmsHostConfig, config.isValid() else {
            ctx._uploadFail(.invalidConfig)
            return
        }
            
        let requestConfig = self.getRequestConfig(config, filename: filename, data: data)
        
        ctx.requester.upload(requestConfig).validate().uploadProgress{ progress in
            ctx._uploadProgress(progress.fractionCompleted)
        }.responseString{ response in
            switch response.result {
            case .success(let value):
                guard let model = ReseponseModel.deserialize(from: value) else {
                    ctx._uploadFail(.invalidResponse)
                    return
                }
                
                if model.success {
                    if let url = model.data?.url {
                        ctx._uploadComplete(url)
                    } else {
                        ctx._uploadFail(model.message, detailError: response.data?.toString())
                    }
                } else if model.code == "image_repeated", let repeatedUrl = model.images {
                    ctx._uploadComplete(repeatedUrl)
                } else {
                    ctx._uploadFail(model.message, detailError: response.data?.toString())
                }
                
            case .failure(let error):
                ctx._uploadFail(error.localizedDescription, detailError: response.data?.toString())
            }
        }
    }
}
