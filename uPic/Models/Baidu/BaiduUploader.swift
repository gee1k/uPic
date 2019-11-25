//
//  BaiduUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/11/19.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class BaiduUploader: BaseUploader {
    
    static let shared = BaiduUploader()
    static let fileExtensions: [String] = []
    
    func _upload(_ fileUrl: URL?, fileData: Data?) {
        guard let host = ConfigManager.shared.getDefaultHost(), let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }
        
        super.start()
        
        let config = data as! BaiduHostConfig
        
        
        let bucket = config.bucket!
        let accessKey = config.accessKey!
        let secretKey = config.secretKey!
        let hostSaveKey = HostSaveKey(rawValue: config.saveKey!)!
        let domain = config.domain!
        let region = BaiduRegion.formatRegion(config.region)
        
        let url = BaiduUtil.computeUrl(bucket: bucket, region: region)
        
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
            retData = BaseUploaderUtil.compressImage(fileData)
            // 处理截图之类的图片，生成一个文件名
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
        let policy = BaiduUtil.getPolicy(policyDict: policyDict)
        
        let signature = BaiduUtil.computeSignature(accessKeySecret: secretKey, encodePolicy: policy)
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("multipart/form-data"))
        
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            multipartFormData.append(key.data(using: .utf8)!, withName: "key")
            multipartFormData.append(accessKey.data(using: .utf8)!, withName: "accessKey")
            multipartFormData.append(policy.data(using: .utf8)!, withName: "policy")
            multipartFormData.append(signature.data(using: .utf8)!, withName: "signature")
            
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
                        super.completed(url: "\(url)/\(key)\(config.suffix ?? "")", retData?.toBase64(), fileUrl, fileName)
                    } else {
                        super.completed(url: "\(domain)/\(key)\(config.suffix ?? "")", retData?.toBase64(), fileUrl, fileName)
                    }
                case .failure(let error):
                    var errorMessage = error.localizedDescription
                    if let data = response.data {
                        let json = JSON(data)
                        let message = json["message"].string
                        errorMessage = message ?? errorMessage
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
