//
//  QiniuUploader.swift
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

    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! QiniuHostConfig


        let bucket = config.bucket!
        let accessKey = config.accessKey!
        let secretKey = config.secretKey!
        let domain = config.domain!
        var region = QiniuRegion.formatRegion(config.region)
        
        let saveKeyPath = config.saveKeyPath
        
        
        guard let url = QiniuRegion.endPoint(region) else {
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

        let scope = "\(bucket):\(saveKey)"

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
            multipartFormData.append(saveKey.data(using: .utf8)!, withName: "key")
        }

        AF.upload(multipartFormData: multipartFormDataGen, to: url, headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
        }.responseJSON(completionHandler: { response -> Void in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let error = json["error"].string
                if error != nil && error!.count > 0 {
                    super.faild(errorMsg: error)
                } else {
                    super.completed(url: "\(domain)/\(saveKey)\(config.suffix!)", retData, fileUrl, fileName)
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
