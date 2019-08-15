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
    
    func _upload(_ fileUrl: URL?, fileData: Data?) {
        guard let host = ConfigManager.shared.getDefaultHost(), let data = host.data else {
            super.faild(errorMsg: NSLocalizedString("bad-host-config", comment: "bad host config"))
            return
        }
        
        super.start()
        
        let config = data as! AliyunHostConfig
        
        
        let bucket = config.bucket!
        let accessKey = config.accessKey!
        let secretKey = config.secretKey!
        let hostSaveKey = HostSaveKey(rawValue: config.saveKey!)!
        let domain = config.domain!
        let region = AliyunRegion.formatRegion(config.region)
        
        let url = AliyunUtil.computeUrl(bucket: bucket, region: region)
        
        if url.isEmpty {
            super.faild(errorMsg: NSLocalizedString("bad-host-config", comment: "bad host config"))
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
            retData = BaseUploaderUtil.compressImage(fileData)
            // MARK: 处理截图之类的图片，生成一个文件名
            let fileType = fileData.contentType() ?? "png"
            fileName = "\(hostSaveKey.getFileName()).\(fileType)"
            mimeType = Util.getMimeType(pathExtension: fileType)
        } else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        
        
        var key = fileName
        if (config.folder != nil && config.folder!.count > 0) {
            key = "\(config.folder!)/\(key)"
        }
        
        // MARK: 加密 policy
        var policyDict = Dictionary<String, Any>()
        let conditions = [["bucket": bucket], ["key": key]]
        policyDict["conditions"] = conditions
        let policy = AliyunUtil.getPolicy(policyDict: policyDict)
        
        let signature = AliyunUtil.computeSignature(accessKeySecret: secretKey, encodePolicy: policy)
        
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/x-www-form-urlencoded;charset=utf-8"))
        
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            multipartFormData.append(key.data(using: .utf8)!, withName: "key")
            multipartFormData.append(accessKey.data(using: .utf8)!, withName: "OSSAccessKeyId")
            multipartFormData.append(policy.data(using: .utf8)!, withName: "policy")
            multipartFormData.append(signature.data(using: .utf8)!, withName: "Signature")
            
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
