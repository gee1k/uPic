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
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! TencentHostConfig


        let bucket = config.bucket!
        let secretId = config.secretId!
        let secretKey = config.secretKey!
        let hostSaveKey = HostSaveKey(rawValue: config.saveKey!)!
        let domain = config.domain!
        let region = TencentRegion.formatRegion(config.region)

        let url = TencentUtil.computeUrl(bucket: bucket, region: region)
        let hostUri = TencentUtil.computeHost(bucket: bucket, region: region)

        if url.isEmpty {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        var retData = fileData
        var fileName = ""
        var mimeType = ""
        if let fileUrl = fileUrl {
            fileName = "\(hostSaveKey.getFileName(filename: fileUrl.lastPathComponent.deletingPathExtension)).\(fileUrl.pathExtension)"
            mimeType = Util.getMimeType(pathExtension: fileUrl.pathExtension)
            retData = BaseUploaderUtil.compressImage(fileUrl)
        } else if let fileData = fileData {
            // MARK: 处理截图之类的图片，生成一个文件名
            let fileType = fileData.contentType() ?? "png"
            fileName = "\(hostSaveKey.getFileName()).\(fileType)"
            mimeType = Util.getMimeType(pathExtension: fileType)
            retData = BaseUploaderUtil.compressImage(fileData)
        } else {
            super.faild(errorMsg: "Invalid file")
            return
        }

        var key = fileName
        if (config.folder != nil && config.folder!.count > 0) {
            key = "\(config.folder!)/\(key)"
        }

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
            multipartFormData.append(key.data(using: .utf8)!, withName: "key")
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
                    super.completed(url: "\(url)/\(key)\(config.suffix ?? "")")
                } else {
                    super.completed(url: "\(domain)/\(key)\(config.suffix ?? "")")
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

    func upload(_ fileUrl: URL) {
        self._upload(fileUrl, fileData: nil)
    }

    func upload(_ fileData: Data) {
        self._upload(nil, fileData: fileData)
    }
}
