//
//  AliyunUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyXMLParser

class AliyunUploader: BaseUploader {
    
    static let shared = AliyunUploader()
    static let fileExtensions: [String] = []
    
    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }
        
        super.start()
        
        let config = data as! AliyunHostConfig
        
        
        let bucket = config.bucket!
        let accessKey = config.accessKey!
        let secretKey = config.secretKey!
        let domain = config.domain!
        let region = AliyunRegion.formatRegion(config.region)
        
        let saveKeyPath = config.saveKeyPath
        
        let url = AliyunUtil.computeUrl(bucket: bucket, region: region)
        
        if url.isEmpty {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }
        
        guard let configuration = BaseUploaderUtil.getSaveConfiguration(fileUrl, fileData, saveKeyPath) else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        let retData = configuration["retData"] as? Data
        let fileName = configuration["fileName"] as! String
        let mimeType = configuration["mimeType"] as! String
        let saveKey = configuration["saveKey"] as! String
        
        // MARK: 加密 policy
        var policyDict = Dictionary<String, Any>()
        let conditions = [
            ["bucket": bucket],
            ["key": saveKey]
        ]
        policyDict["conditions"] = conditions
        let policy = AliyunUtil.getPolicy(policyDict: policyDict)
        
        let signature = AliyunUtil.computeSignature(accessKeySecret: secretKey, encodePolicy: policy)
        
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/x-www-form-urlencoded;charset=utf-8"))
        
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            multipartFormData.append(saveKey.data(using: .utf8)!, withName: "key")
            multipartFormData.append(accessKey.data(using: .utf8)!, withName: "OSSAccessKeyId")
            multipartFormData.append(policy.data(using: .utf8)!, withName: "policy")
            multipartFormData.append(signature.data(using: .utf8)!, withName: "Signature")
            multipartFormData.append(mimeType.data(using: .utf8)!, withName: "Content-Type")
            
            if retData != nil {
                multipartFormData.append(retData!, withName: "file", fileName: fileName, mimeType: mimeType)
            } else if fileUrl != nil {
                multipartFormData.append(fileUrl!, withName: "file", fileName: fileName, mimeType: mimeType)
            }
        }
        
        
        AF.upload(multipartFormData: multipartFormDataGen, to: url, headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
            }.response(completionHandler: { response -> Void in
                switch response.result {
                case .success(_):
                    if domain.isEmpty {
                        super.completed(url: "\(url)/\(saveKey)\(config.suffix!)", retData, fileUrl, fileName)
                    } else {
                        super.completed(url: "\(domain)/\(saveKey)\(config.suffix!)", retData, fileUrl, fileName)
                    }
                case .failure(let error):
                    var errorMessage = error.localizedDescription
                    if let data = response.data {
                        let xml = XML.parse(data)
                        if let errorMsg = xml.Error.Message.text {
                            errorMessage = errorMsg
                        }
                    }
                    super.faild(errorMsg: errorMessage)
                }
            })
        
    }
    
    func upload(_ fileUrl: URL, host: Host) {
        self._upload(fileUrl, fileData: nil, host: host)
    }
    
    func upload(_ fileData: Data, host: Host) {
        self._upload(nil, fileData: fileData, host: host)
    }
}
