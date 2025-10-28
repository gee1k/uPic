//
//  Aliyun.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

public class AliyunUploader {
    
    internal static let allowExtensions: [String] = []
    
    private static func generateSignature(_ config: AliyunHostConfig, saveKey: String) -> String? {
        let date = Date().toUTCString()
        let signString = "PUT\n\n\(saveKey.mimeType)\n\(date)\n/\(config.bucket!)/\(saveKey)"
        
        let b64 = signString.calculateHMACByKey(key: config.secretKey!).toBase64()
        
        let signature = "OSS \(config.accessKey!):\(b64)"
        
        return signature
    }
    
    private static func getRequestConfig(_ config: AliyunHostConfig, saveKey: String, signature: String, data: Data) -> RequestConfig {
        let host = "\(config.bucket!).\(AliyunRegion.endPoint(config.region!))"
        
        var headers = HTTPHeaders()
        headers.add(.authorization(signature))
        headers.add(.contentType(saveKey.mimeType))
        headers.add(name: "Host", value: host)
        headers.add(name: "Date", value: Date().toUTCString())
        
        var requestConfig = RequestConfig()
        requestConfig.url = "https://\(host)/\(saveKey.urlEncoded())"
        requestConfig.method = .put
        requestConfig.headers = headers
        requestConfig.data = data
        
        return requestConfig
    }
    
    internal static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.getConfig(AliyunHostConfig.self), config.isValid() else {
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
                let url = domain.isEmpty ? requestConfig.url! : "\(domain)/\(saveKey)"
                let retUrl = "\(url)\(config.suffix)"
                ctx._uploadComplete(retUrl)
            case .failure(let error):
                var errorMessage = error.localizedDescription
                if let data = response.data {
                    let xml = XMLHash.parse(data)
                    if let errorMsg = xml["Error"]["Message"].element?.text {
                        errorMessage = errorMsg
                    }
                }
                ctx._uploadFail(errorMessage, detailError: response.data?.toString())
            }
        }
    }
}
