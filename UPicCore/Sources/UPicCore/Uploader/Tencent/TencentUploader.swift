//
//  Tencent.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

public class TencentUploader {
    
    internal static let allowExtensions: [String] = []
    
    private static let expiration = 8000
    
    private static func generateSignature(_ config: TencentHostConfig, saveKey: String, signTime:String, host: String) -> String {
        // https://cloud.tencent.com/document/product/436/7778#signature
        let signKey = signTime.calculateHMACByKey(key: config.secretKey!).toHexString()
        let httpString = "put\n/\(saveKey)\n\nhost=\(host)\n"
        let sha1edHttpString = httpString.sha1()
        let stringToSign = "sha1\n\(signTime)\n\(sha1edHttpString)\n"
        let signature = stringToSign.calculateHMACByKey(key: signKey)
        return signature.toHexString()
    }
    
    private static func getRequestConfig(_ config: TencentHostConfig, saveKey: String, data: Data) -> RequestConfig {
        
        let host = "\(config.bucket!).\(TencentRegion.endPoint(config.region!))"
        
        let signTime = "\(Date().secondStamp);\(Date().secondStamp + expiration)"
        
        let signature = generateSignature(config, saveKey: saveKey, signTime: signTime, host: host)
        
        let authorization = "q-sign-algorithm=sha1&q-ak=\(config.secretId!)&q-sign-time=\(signTime)&q-key-time=\(signTime)&q-header-list=host&q-url-param-list=&q-signature=\(signature)"
        
        var headers = HTTPHeaders()
        headers.add(.authorization(authorization))
        headers.add(.contentType(saveKey.mimeType))
        headers.add(name: "Host", value: host)
        
        var requestConfig = RequestConfig()
        requestConfig.url = "https://\(host)/\(saveKey.urlEncoded())"
        requestConfig.method = .put
        requestConfig.headers = headers
        requestConfig.data = data
        
        return requestConfig
    }
    
    internal static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.data as? TencentHostConfig, config.isValid() else {
            ctx._uploadFail(.invalidConfig)
            return
        }
        
        let domain = config.domain
        let saveKey = FormatUtil.parseSaveKeyPath(config.saveKeyPath, filename)
        
        let requestConfig = self.getRequestConfig(config, saveKey: saveKey, data: data)
        
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
