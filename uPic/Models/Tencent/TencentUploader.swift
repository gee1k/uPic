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

    func _upload(_ fileUrl: URL?, fileData: Data?) {
        guard let host = ConfigManager.shared.getDefaultHost(), let data = host.data else {
            super.faild(errorMsg: NSLocalizedString("bad-host-config", comment: "bad host config"))
            return
        }

        super.start()

        let config = data as! TencentHostConfig


        let bucket = config.bucket!
        let secretId = config.secretId!
        let secretKey = config.secretKey!
        let hostSaveKey = HostSaveKey(rawValue: config.saveKey!)!
        let domain = config.domain!
        let region = (config.region != nil ? TencentRegion(rawValue: config.region!) : TencentRegion.ap_shanghai)!

        let url = TencentUtil.computeUrl(bucket: bucket, region: region)
        let hostUri = TencentUtil.computeHost(bucket: bucket, region: region)

        if url.isEmpty {
            super.faild(errorMsg: NSLocalizedString("bad-host-config", comment: "bad host config"))
            return
        }

        var fileName = ""
        var mimeType = ""
        if fileUrl != nil {
            fileName = "\(hostSaveKey.getFileName(filename: fileUrl!.lastPathComponent.deletingPathExtension)).\(fileUrl!.pathExtension)"
            mimeType = Util.getMimeType(pathExtension: fileUrl!.pathExtension)
        } else {
            // MARK: 处理截图之类的图片，生成一个文件名
            fileName = "\(hostSaveKey.getFileName()).png"
            mimeType = Util.getMimeType(pathExtension: "png")
        }

        var key = fileName
        if (config.folder != nil && config.folder!.count > 0) {
            key = "\(config.folder!)/\(key)"
        }

        // MARK: 签名部分
        let qSignAlgorithm = "sha1"
        let qKeyTime = TencentUtil.getKeyTime()
        let signKey = qKeyTime.calculateHMACByKey(key: secretKey).toHexString()
        // MARK: 加密 policy
        var policyDict = Dictionary<String, Any>()
        let conditions = [["bucket": bucket], ["key": key], ["q-sign-time": qKeyTime], ["q-sign-algorithm": qSignAlgorithm], ["q-ak": secretId]]
        policyDict["conditions"] = conditions
        let policy = TencentUtil.getPolicy(policyDict: policyDict)

        // improtant - start
        let httpString = "post\n/\n\n\n"
        let stringToSign = "\(qSignAlgorithm)\n\(qKeyTime)\n\(httpString.toSha1())\n"
        let qSignature = stringToSign.calculateHMACByKey(key: signKey).toHexString()

        let authorization = [
            "q-sign-algorithm=" + qSignAlgorithm,
            "q-ak=" + secretId,
            "q-sign-time=" + qKeyTime,
            "q-key-time=" + qKeyTime,
            "q-header-list=",
            "q-url-param-list=",
            "q-signature=" + qSignature
        ].joined(separator: "&")


        var headers = HTTPHeaders()
        headers.add(HTTPHeader.authorization(authorization))
        headers.add(HTTPHeader.contentType("multipart/form-data"))
        headers.add(HTTPHeader(name: "Host", value: hostUri))
        // improtant - end
        
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            multipartFormData.append(key.data(using: .utf8)!, withName: "key")
            multipartFormData.append(policy.data(using: .utf8)!, withName: "policy")
            if fileUrl != nil {
                multipartFormData.append(fileUrl!, withName: "file", fileName: fileName, mimeType: mimeType)
            } else {
                multipartFormData.append(fileData!, withName: "file", fileName: fileName, mimeType: mimeType)
            }
        }
        

        AF.upload(multipartFormData: multipartFormDataGen, to: url, headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
        }.response(completionHandler: { response -> Void in
            switch response.result {
            case .success(_):
                super.completed(url: "\(domain)/\(key)")
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

    func upload(_ fileUrl: URL) {
        self._upload(fileUrl, fileData: nil)
    }

    func upload(_ fileData: Data) {
        self._upload(nil, fileData: fileData)
    }
}
