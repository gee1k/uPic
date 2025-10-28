//
//  Qiniu.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON

private struct QiniuPutPolicy: Codable {
    let scope: String
    let deadline: Int
}

private struct ReseponseModel: HandyJSON {
    var hash: String?
    var key: String?
    var error: String?
}

public class QiniuUploader {
    
    internal static let allowExtensions: [String] = []
    
    private static let expiration = 1800
    
    private static func getToken(scope: String, accessKey: String, secretKey: String) -> String {

        let deadline = Date().secondStamp + expiration
        let putPolicy = QiniuPutPolicy.init(scope: scope, deadline: Int(deadline))

        let jsonData = try! JSONEncoder().encode(putPolicy)
        let base64String = jsonData.base64EncodedString().urlSafeBase64()

        let hmac = base64String.calculateHMACByKey(key: secretKey)
        let encodeString = hmac.toBase64()
        let encodedSignString = encodeString.urlSafeBase64()
        return "\(accessKey):\(encodedSignString):\(base64String)"
    }
    
    private static func getRequestConfig(_ config: QiniuHostConfig, saveKey: String, token: String, data: Data) -> RequestConfig {
        
        var headers = HTTPHeaders()
        headers.add(.contentType("application/x-www-form-urlencoded;charset=utf-8"))
        
        let multipartFormData = MultipartFormData()
        multipartFormData.append(saveKey.data(using: .utf8)!, withName: "key")
        multipartFormData.append(token.data(using: .utf8)!, withName: "token")
        multipartFormData.append(data, withName: "file", fileName: saveKey.lastPathComponent, mimeType: saveKey.mimeType)
        
        var requestConfig = RequestConfig()
        requestConfig.url = QiniuRegion.endPoint(config.region!)
        requestConfig.method = .post
        requestConfig.headers = headers
        requestConfig.multipartFormData = multipartFormData
        
        return requestConfig
    }
    
    internal static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.getConfig(QiniuHostConfig.self), config.isValid() else {
            ctx._uploadFail(.invalidConfig)
            return
        }
        
        let domain = config.domain
        let saveKey = FormatUtil.parseSaveKeyPath(config.saveKeyPath, filename)
        
        let scope = "\(config.bucket!):\(saveKey)"
        
        let token = getToken(scope: scope, accessKey: config.accessKey!, secretKey: config.secretKey!)
        
        let requestConfig = self.getRequestConfig(config, saveKey: saveKey, token: token, data: data)
        
        ctx.requester.upload(requestConfig).validate().uploadProgress{ progress in
            ctx._uploadProgress(progress.fractionCompleted)
        }.responseString{ response in
            switch response.result {
            case .success(let value):
                if let model = ReseponseModel.deserialize(from: value), let error = model.error {
                    ctx._uploadFail(error, detailError: response.data?.toString())
                    return
                }
                
                let retUrl = "\(domain)/\(saveKey)\(config.suffix)"
                ctx._uploadComplete(retUrl)
            case .failure(let error):
                var errorMessage = error.localizedDescription
                if let resData = response.data, let resString = String(data: resData, encoding: .utf8),
                    let model = ReseponseModel.deserialize(from: resString), let message = model.error {
                    errorMessage = message
                }
                ctx._uploadFail(errorMessage, detailError: response.data?.toString())
            }
        }
    }
}
