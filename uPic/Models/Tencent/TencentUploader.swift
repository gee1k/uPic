//
//  TencentUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyXMLParser

class TencentUploader: BaseUploader {

    static let shared = TencentUploader()
    static let fileExtensions: [String] = []

    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! TencentHostConfig


        let bucket = config.bucket!
        let secretId = config.secretId!
        let secretKey = config.secretKey!
        let domain = config.domain!
        let region = TencentRegion.formatRegion(config.region)
        
        let saveKeyPath = config.saveKeyPath

        let url = TencentUtil.computeUrl(bucket: bucket, region: region)
        let hostUri = TencentUtil.computeHost(bucket: bucket, region: region)

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

        // MARK: 签名部分
        let qSignAlgorithm = "sha1"
        let qKeyTime = TencentUtil.getKeyTime()
        let signKey = qKeyTime.calculateHMACByKey(key: secretKey).toHexString()

        let httpString = "post\n/\n\nhost=\(hostUri)\n"
        let stringToSign = "\(qSignAlgorithm)\n\(qKeyTime)\n\(httpString.toSha1())\n"
        let qSignature = stringToSign.calculateHMACByKey(key: signKey).toHexString()

        let authorization = [
            "q-sign-algorithm=" + qSignAlgorithm,
            "q-ak=" + secretId,
            "q-sign-time=" + qKeyTime,
            "q-key-time=" + qKeyTime,
            "q-header-list=host",
            "q-url-param-list=",
            "q-signature=" + qSignature
        ].joined(separator: "&")


        var headers = HTTPHeaders()
        headers.add(HTTPHeader.authorization(authorization))
        headers.add(HTTPHeader.contentType("multipart/form-data"))
        headers.add(HTTPHeader(name: "Host", value: hostUri))
        
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            multipartFormData.append(saveKey.data(using: .utf8)!, withName: "key")
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
