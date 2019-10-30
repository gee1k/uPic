//
//  WeiboUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class WeiboUploader: BaseUploader {

    static let shared = WeiboUploader()
    static let fileExtensions: [String] = ["jpeg", "jpg", "png", "gif", "bmp"]
    
    let url = "http://picupload.service.weibo.com/interface/pic_upload.php?ori=1&mime=image%2Fjpeg&data=base64&url=0&markpos=1&logo=&nick=0&marks=1&app=miniblog"

    func _upload(_ fileUrl: URL?, fileData: Data?) {
        guard let host = ConfigManager.shared.getDefaultHost(), let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! WeiboHostConfig


        let username = config.username!
        let password = config.password!
        let cookieMode = config.cookieMode == "1" ? true : false
        let cookie = config.cookie!
        let quality = config.quality!
        
        if cookieMode && cookie.isEmpty {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        } else if !cookieMode && (username.isEmpty || password.isEmpty) {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }
        
        // MARK: 上传
        func _uploadHandler(_ loginCookie: String?) {
            var fileBase64 = ""
            var fileExtension = ".jpg"
         
            if let fileUrl = fileUrl  {
                if fileUrl.pathExtension == "gif" {
                    fileExtension = ".gif"
                }
                do {
                    var data = try Data(contentsOf: fileUrl)
                    data = BaseUploaderUtil.compressImage(data)
                    fileBase64 = data.toBase64()
                } catch {
                    super.faild(errorMsg: "Invalid file")
                    return
                }
            } else if let fileData = fileData {
                let retData = BaseUploaderUtil.compressImage(fileData)
                fileBase64 = retData.toBase64()
            } else {
                super.faild(errorMsg: "Invalid file")
                return
            }
            
            
            var headers = HTTPHeaders()
            if let loginCookie = loginCookie {
                headers.add(name: "Cookie", value: loginCookie)
            }
            
            func multipartFormDataGen(multipartFormData: MultipartFormData) {
                multipartFormData.append(fileBase64.data(using: .utf8)!, withName: "b64_data")
            }
            
            AF.upload(multipartFormData: multipartFormDataGen, to: url, headers: headers).validate().uploadProgress { progress in
                super.progress(percent: progress.fractionCompleted)
                }.responseString(completionHandler: { response -> Void in
                    switch response.result {
                    case .success(let value):
                        if let pidPid = WeiboUtil.parsePicPid(reponseString: value) {
                            super.completed(url: "https://ws1.sinaimg.cn/\(quality)/\(pidPid)\(fileExtension)", fileBase64, fileUrl, nil)
                        } else {
                            super.faild(errorMsg: "Upload failed, please check the configuration!".localized)
                        }
                    case .failure(let error):
                        super.faild(errorMsg: error.localizedDescription)
                    }
                })
        }
        
        
        if cookieMode {
            // Cookie 模式，直接使用配置的 cookie 上传
            _uploadHandler(cookie)
        } else {
            self._login(username: username, password: password, callback: {(errorMsg, loginCookie) -> Void in
                if errorMsg == nil {
                    _uploadHandler(loginCookie)
                } else {
                    super.faild(errorMsg: errorMsg)
                }
            })
        }
    }

    func upload(_ fileUrl: URL) {
        self._upload(fileUrl, fileData: nil)
    }

    func upload(_ fileData: Data) {
        self._upload(nil, fileData: fileData)
    }
    
    // MARK: 通过用户名密码登录，获取 cookie
    func _login(username: String, password: String, callback: @escaping ((_ errorMsg: String?, _ loginCookie: String?) -> Void)) {
        let loginUrl = "https://passport.weibo.cn/sso/login"
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/x-www-form-urlencoded"))
        headers.add(name: "Referer", value: loginUrl)
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            multipartFormData.append(username.data(using: .utf8)!, withName: "username")
            multipartFormData.append(password.data(using: .utf8)!, withName: "password")
        }
        
        
        AF.upload(multipartFormData: multipartFormDataGen, to: loginUrl, headers: headers).validate().responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    let loginCookie = response.response?.headers.value(for: "Set-Cookie")
                    let json = JSON(value)
                    if json["retcode"].intValue == 20000000 {
                        callback(nil, loginCookie)
                    } else {
                        callback(json["msg"].string ?? "unknown error", nil)
                    }
                case .failure(let error):
                    callback(error.localizedDescription, nil)
                }
            })
    }
}
