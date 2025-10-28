//
//  Upyun.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire

public class UpyunUploader {
    
    internal static let allowExtensions: [String] = []
    
    private static func generateSignature(_ config: UpyunHostConfig, saveKey: String) -> String? {
        let md5Password = config.password!.md5()
        let date = Date().toUTCString()
        let uri = "/\(config.bucket!)/\(saveKey.urlEncoded())"
        let value = "PUT&\(uri)&\(date)"
        
        let sign = value.calculateHMACByKey(key: md5Password).toBase64()
        guard let operatorName = config.operatorName else {
            return nil
        }
        return "UPYUN \(operatorName):\(sign)"
    }
    
    private static func getRequestConfig(_ config: UpyunHostConfig, saveKey: String, signature: String, data: Data) -> RequestConfig {
        
        var headers = HTTPHeaders()
        headers.add(.authorization(signature))
        headers.add(.contentType(saveKey.mimeType))
        headers.add(name: "Date", value: Date().toUTCString())
        
        var requestConfig = RequestConfig()
        requestConfig.url = "https://v0.api.upyun.com/\(config.bucket!)/\(saveKey.urlEncoded())"
        requestConfig.method = .put
        requestConfig.headers = headers
        requestConfig.data = data
        
        return requestConfig
    }
    
    internal static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.data as? UpyunHostConfig, config.isValid() else {
            ctx._uploadFail(.invalidConfig)
            return
        }
        
        let domain = config.domain
        let saveKey = FormatUtil.parseSaveKeyPath(config.saveKeyPath, filename)
        
        guard let signature = generateSignature(config, saveKey: saveKey) else {
            ctx._uploadFail(.invalidSignature)
            return
        }
        
        let requestConfig = self.getRequestConfig(config, saveKey: saveKey, signature: signature, data: data)
        
        ctx.requester.upload(requestConfig).validate().uploadProgress{ progress in
            ctx._uploadProgress(progress.fractionCompleted)
        }.response{ response in
            switch response.result {
            case .success(_):
                let retUrl = "\(domain)/\(saveKey)\(config.suffix)"
                ctx._uploadComplete(retUrl)
            case .failure(let error):
                ctx._uploadFail(error.localizedDescription, detailError: response.data?.toString())
            }
        }
    }
}
