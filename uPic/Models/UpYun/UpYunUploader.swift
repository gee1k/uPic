//
//  UpYunUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/10.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Alamofire

class UpYunUploader: BaseUploader {

    static let shared = UpYunUploader()

    let url = "https://v0.api.upyun.com/"

    static let fileExtensions: [String] = []

    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! UpYunHostConfig


        let bucket = config.bucket!
        let operatorName = config.operatorName!
        let password = config.password!
        let domain = config.domain!
        
        let saveKeyPath = config.saveKeyPath

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
        policyDict["bucket"] = bucket
        policyDict["save-key"] = saveKey

        let policy = UpYunUtil.getPolicy(policyDict: policyDict)

        // MARK: 加密 signature
        let signatureParams = ["POST", "/\(bucket)", policy]
        let signatureStr = signatureParams.joined(separator: "&")
        let hmac = signatureStr.calculateHMACByKey(key: password.toMd5())
        let signature = hmac.toBase64()!

        // MARK: 生成 authorization
        let authorization = "UPYUN \(operatorName):\(signature)"

        var headers = HTTPHeaders()
        headers.add(HTTPHeader.authorization(authorization))
        headers.add(HTTPHeader.contentType("application/x-www-form-urlencoded;charset=utf-8"))
        
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            if retData != nil {
                multipartFormData.append(retData!, withName: "file", fileName: fileName, mimeType: mimeType)
            } else if fileUrl != nil {
                multipartFormData.append(fileUrl!, withName: "file", fileName: fileName, mimeType: mimeType)
            }
            multipartFormData.append(authorization.data(using: .utf8)!, withName: "authorization")
            multipartFormData.append(policy.data(using: .utf8)!, withName: "policy")
        }

        AF.upload(multipartFormData: multipartFormDataGen, to: "\(url)\(bucket)", headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
        }.responseJSON(completionHandler: { response -> Void in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let code = json["code"]
                if 200 == code {
                    super.completed(url: "\(domain)/\(saveKey)\(config.suffix!)", retData, fileUrl, fileName)
                } else {
                    super.faild(errorMsg: json["message"].string)
                }
            case .failure(let error):
                super.faild(errorMsg: error.localizedDescription)
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
