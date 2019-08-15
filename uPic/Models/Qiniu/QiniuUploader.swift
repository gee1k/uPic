//
//  AliyunUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Alamofire

class QiniuUploader: BaseUploader {

    static let shared = QiniuUploader()

    static let fileExtensions: [String] = []

    func _upload(_ fileUrl: URL?, fileData: Data?) {
        guard let host = ConfigManager.shared.getDefaultHost(), let data = host.data else {
            super.faild(errorMsg: NSLocalizedString("bad-host-config", comment: "bad host config"))
            return
        }

        super.start()

        let config = data as! QiniuHostConfig


        let bucket = config.bucket!
        let accessKey = config.accessKey!
        let secretKey = config.secretKey!
        let hostSaveKey = HostSaveKey(rawValue: config.saveKey!)!
        let domain = config.domain!
        var region = QiniuRegion.formatRegion(config.region)

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

        let scope = "\(bucket):\(key)"

        // MARK: 生成 token
        let token = QiniuUtil.getToken(scope: scope, accessKey: accessKey, secretKey: secretKey)


        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/x-www-form-urlencoded;charset=utf-8"))
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            if retData != nil {
                multipartFormData.append(retData!, withName: "file", fileName: fileName, mimeType: mimeType)
            } else if fileUrl != nil {
                multipartFormData.append(fileUrl!, withName: "file", fileName: fileName, mimeType: mimeType)
            }
            
            multipartFormData.append(token.data(using: .utf8)!, withName: "token")
            multipartFormData.append(key.data(using: .utf8)!, withName: "key")
        }

        AF.upload(multipartFormData: multipartFormDataGen, to: region.url, headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
        }.responseJSON(completionHandler: { response -> Void in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let error = json["error"].string
                if error != nil && error!.count > 0 {
                    super.faild(errorMsg: error)
                } else {
                    super.completed(url: "\(domain)/\(key)\(config.suffix ?? "")")
                }
            case .failure(let error):
                super.faild(errorMsg: error.localizedDescription)
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
