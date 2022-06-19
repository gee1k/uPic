//
//  LskyUploader.swift
//  uPic
//
//  Created by Svend Jin on 2020/2/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//
import Cocoa
import Alamofire
import SwiftyJSON

class LskyProUploader: BaseUploader {

    static let shared = LskyProUploader()
    static let fileExtensions: [String] = []

    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! LskyProHostConfig


        let email = config.email
        let password = config.password
        let isAnonymous = config.isAnonymous
        let domain = config.domain
        
        if domain.isEmpty {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }
        
        if !isAnonymous && (email.isEmpty || password.isEmpty) {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }
        
        // MARK: 上传
        func _uploadHandler(_ token: String?) {
            
            guard let configuration = BaseUploaderUtil.getSaveConfiguration(fileUrl, fileData, nil) else {
                super.faild(errorMsg: "Invalid file")
                return
            }
            let retData = configuration["retData"] as? Data
            let fileName = configuration["fileName"] as! String
            let mimeType = configuration["mimeType"] as! String
            
            var headers = HTTPHeaders()
            if let token = token {
                headers.add(name: "token", value: token)
            }
            
            func multipartFormDataGen(multipartFormData: MultipartFormData) {
                if retData != nil {
                    multipartFormData.append(retData!, withName: "image", fileName: fileName, mimeType: mimeType)
                } else if fileUrl != nil {
                    multipartFormData.append(fileUrl!, withName: "image", fileName: fileName, mimeType: mimeType)
                }
            }
            
            let url = "\(domain)/api/upload"
            AF.upload(multipartFormData: multipartFormDataGen, to: url, headers: headers).validate().uploadProgress { progress in
                super.progress(percent: progress.fractionCompleted)
                }.responseData(completionHandler: { response -> Void in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let retUrl = json["data"]["url"].stringValue
                        let retName = json["data"]["name"].stringValue
                        if json["code"].intValue == 200 {
                            super.completed(url: retUrl, retData, fileUrl, retName)
                        } else {
                            super.faild(responseData: response.data, errorMsg: json["msg"].string ?? "unknown error")
                        }
                    case .failure(_):
                        super.faild(responseData: response.data)
                    }
                })
        }
        
        
        if isAnonymous {
            _uploadHandler(nil)
        } else {
            self._getToken(config: config, callback: {(errorMsg, token) -> Void in
                if errorMsg == nil {
                    _uploadHandler(token)
                } else {
                    super.faild(errorMsg: errorMsg)
                }
            })
        }
    }

    func upload(_ fileUrl: URL, host: Host) {
        self._upload(fileUrl, fileData: nil, host: host)
    }
    
    func upload(_ fileData: Data, host: Host) {
        self._upload(nil, fileData: fileData, host: host)
    }
    
    func _getToken(config: LskyProHostConfig, callback: @escaping ((_ errorMsg: String?, _ token: String?) -> Void)) {
        
        let email = config.email
        let password = config.password
        let domain = config.domain
        let loginUrl = "\(domain)/api/token"
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/x-www-form-urlencoded"))
        headers.add(name: "Referer", value: loginUrl)
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            multipartFormData.append(email.data(using: .utf8)!, withName: "email")
            multipartFormData.append(password.data(using: .utf8)!, withName: "password")
        }
        
        
        AF.upload(multipartFormData: multipartFormDataGen, to: loginUrl, headers: headers).validate().responseData(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let token = json["data"]["token"].stringValue
                    if json["code"].intValue == 200 {
                        callback(nil, token)
                    } else {
                        callback(json["msg"].string ?? "unknown error", nil)
                    }
                case .failure(let error):
                    callback(error.localizedDescription, nil)
                }
            })
    }
}
