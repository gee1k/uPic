//
//  Baidu.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON

private struct ErrorModel: HandyJSON {
    var code: String?
    var message: String?
    var requestId: String?
}

public class BaiduUploader {
    
    internal static let allowExtensions: [String] = []
    
    private static let EXPIRATION_TIME = 1800
    
    private static func getPolicy(bucket: String, saveKey: String) -> String? {
        var policyDict = Dictionary<String, Any>()
        let conditions: [Any] = [
            ["bucket": bucket],
            ["key": saveKey]
        ]
        policyDict["conditions"] = conditions
        
        let expiration = Date(timeIntervalSince1970: TimeInterval(Date().secondStamp + EXPIRATION_TIME)).format(dateFormat: "yyyy-MM-dd'T'HH:mm:ss'Z'", timeZone: TimeZone(secondsFromGMT: 0))
        
        policyDict["expiration"] = expiration
        
        let jsonData = try? JSONSerialization.data(withJSONObject: policyDict, options: [])
        return jsonData?.base64EncodedString()
    }
    
    private static func getRequestConfig(_ config: BaiduHostConfig, saveKey: String, data: Data) -> RequestConfig? {
        
        let mimeType = saveKey.mimeType
        
        guard let region = config.region else {
            return nil
        }
        
        guard let policy = getPolicy(bucket: config.bucket!, saveKey: saveKey) else {
            return nil
        }
        
        let signature = policy.calculateHMAC256ByKey(key: config.secretKey!).toHexString()
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("multipart/form-data"))
        
        let multipartFormData = MultipartFormData()
        multipartFormData.append(saveKey.data(using: .utf8)!, withName: "key")
        multipartFormData.append(config.accessKey!.data(using: .utf8)!, withName: "accessKey")
        multipartFormData.append(policy.data(using: .utf8)!, withName: "policy")
        multipartFormData.append(signature.data(using: .utf8)!, withName: "signature")
        multipartFormData.append(mimeType.data(using: .utf8)!, withName: "content-type")
        multipartFormData.append(data, withName: "file", fileName: saveKey.lastPathComponent, mimeType: mimeType)
        
        var requestConfig = RequestConfig()
        requestConfig.url = "https://\(config.bucket!).\(BaiduRegion.endPoint(region))"
        requestConfig.method = .post
        requestConfig.multipartFormData = multipartFormData
        requestConfig.headers = headers
        
        return requestConfig
    }
    
    internal static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.getConfig(BaiduHostConfig.self), config.isValid() else {
            ctx._uploadFail(.invalidConfig)
            return
        }
        
        let domain = config.domain
        let saveKey = FormatUtil.parseSaveKeyPath(config.saveKeyPath, filename)
        
        guard let requestConfig = getRequestConfig(config, saveKey: saveKey, data: data) else {
            ctx._uploadFail(.invalidSignature)
            return
        }
        
        ctx.requester.upload(requestConfig).validate().uploadProgress{ progress in
            ctx._uploadProgress(progress.fractionCompleted)
        }.response{ response in
            switch response.result {
            case .success(_):
                let url = domain.isEmpty ? requestConfig.url! : domain
                let retUrl = "\(url)/\(saveKey)\(config.suffix)"
                ctx._uploadComplete(retUrl)
            case .failure(let error):
                var errorMessage = error.localizedDescription
                if let resData = response.data, let resString = String(data: resData, encoding: .utf8),
                    let model = ErrorModel.deserialize(from: resString), let message = model.message {
                    errorMessage = message
                }
                ctx._uploadFail(errorMessage, detailError: response.data?.toString())
            }
        }
    }
}
