//
//  MinioUploader.swift
//  uPic
//
//  Created by Svend Jin on 2020/4/12.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyXMLParser

class MinioUploader: BaseUploader {

    static let shared = MinioUploader()
    static let fileExtensions: [String] = []

    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! MinioHostConfig
        let endPoint = config.url
        let bucket = config.bucket
        let accessKey = config.accessKey
        let secretKey = config.secretKey
//        let domain = config.domain
        let region = AmazonS3Region.formatRegion(config.region)
        
        let saveKeyPath = config.saveKeyPath

        guard let configuration = BaseUploaderUtil.getSaveConfiguration(fileUrl, fileData, saveKeyPath) else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        let retData = configuration["retData"] as? Data
        let fileName = configuration["fileName"] as! String
        let mimeType = configuration["mimeType"] as! String
        let saveKey = configuration["saveKey"] as! String
        
        let url = MinioUtil.computeUrl(endPoint: endPoint, bucket: bucket, saveKey: saveKey)

        if url.isEmpty {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }
        
        let suffix = BaseUploaderUtil._parseVariables(config.suffix, fileName, otherVariables: nil)
        

        // MARK: 加密 policy
        let iso_date = Date().format(dateFormat: "yyyyMMdd'T'HHmmss'Z'", timeZone: TimeZone(secondsFromGMT: 0))
        let short_date = Date().format(dateFormat: "yyyyMMdd", timeZone: TimeZone(secondsFromGMT: 0))
        
        let credential = AmazonS3Util.getCredential(access_key: accessKey, short_date: short_date, region: region)
        
        var policyDict = Dictionary<String, Any>()
        let conditions: [Any] = [
            ["acl": "public-read"],
            ["bucket": bucket],
            ["starts-with", "$key", ""],
            ["x-amz-credential": credential],
            ["x-amz-algorithm": AmazonS3Util.ALGORITHM],
            ["X-amz-date": iso_date],
            ["content-type": mimeType] // 如不手动设置 content-type ， aws 默认会将文件的 content-type 设置为 binary/octet-stream 。访问时将会直接下载，而不是预览
        ]
        policyDict["conditions"] = conditions
        let policy = AmazonS3Util.getPolicy(policyDict: policyDict)

        let signature = AmazonS3Util.computeSignature(secret_key: secretKey, policy: policy, region: region, short_date: short_date)
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("multipart/form-data"))
        headers.add(name: "key", value: saveKey)
        headers.add(name: "acl", value: "public-read")
        headers.add(name: "X-Amz-Credential", value: credential)
        headers.add(name: "X-Amz-Algorithm", value: AmazonS3Util.ALGORITHM)
        headers.add(name: "X-Amz-Date", value: iso_date)
        headers.add(name: "policy", value: policy)
        headers.add(name: "X-Amz-Signature", value: signature)
        AF.upload(retData!, to: url, method: .put, headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
        }.response(completionHandler: { response -> Void in
            switch response.result {
            case .success(_):
                super.completed(url: "\(url)\(suffix)", retData, fileUrl, fileName)
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
