//
//  Weibo.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON


private struct LoginRetModel: HandyJSON {
    var retcode: Int!
    var msg: String?
}

public class WeiboUploader {
    
    internal static let allowExtensions: [String] = ["jpeg", "jpg", "png", "gif", "bmp"]
    
    private static let UPLOAD_URL = "https://picupload.weibo.com/interface/pic_upload.php?ori=1&mime=image%2Fjpeg&data=base64&url=0&markpos=1&logo=&nick=0&marks=1&app=miniblog"
   
    private static func getRequestConfig(_ config: WeiboHostConfig, loginCookie: String, filename: String, data: Data) -> RequestConfig {
        
        var headers = HTTPHeaders()
        headers.add(name: "Cookie", value: loginCookie)
       
        let multipartFormData = MultipartFormData()
        multipartFormData.append(data.base64EncodedData(), withName: "b64_data")
        
        var requestConfig = RequestConfig()
        requestConfig.url = UPLOAD_URL
        requestConfig.method = .post
        requestConfig.headers = headers
        requestConfig.multipartFormData = multipartFormData
        
        return requestConfig
    }
    
    internal static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.data as? WeiboHostConfig, config.isValid() else {
            ctx._uploadFail(.invalidConfig)
            return
        }
        
        if config.cookieMode {
            guard let cookie = config.cookie else {
                ctx._uploadFail(.invalidConfig)
                return
            }
            _upload(ctx, config: config, data: data, filename: filename, loginCookie: cookie)
        } else {
            guard let username = config.username, let password = config.password else {
                ctx._uploadFail(.invalidConfig)
                return
            }
            _login(ctx, username: username, password: password){ (error, cookie) in
               guard let cookie = cookie else {
                    ctx._uploadFail(error)
                    return
                }
                _upload(ctx, config: config, data: data, filename: filename, loginCookie: cookie)
            }
        }
    }
    
    // MARK: - upload image
    private static func _upload(_ ctx: UPicCore, config: WeiboHostConfig, data: Data, filename: String, loginCookie: String) {

        let fileExtension = filename.pathExtension == "gif" ? ".gif" : ".jpg"
        
        let requestConfig = self.getRequestConfig(config, loginCookie: loginCookie, filename: filename, data: data)
        
        ctx.requester.upload(requestConfig).validate().uploadProgress{ progress in
            ctx._uploadProgress(progress.fractionCompleted)
        }.responseString{ response in
            switch response.result {
            case .success(let value):
                if let pidPid = parsePicPid(reponseString: value) {
                    ctx._uploadComplete("\(config.domain)/\(config.quality)/\(pidPid)\(fileExtension)")
                } else {
                    ctx._uploadFail(.invalidResponse)
                }
            case .failure(let error):
                ctx._uploadFail(error.localizedDescription, detailError: response.data?.toString())
            }
        }
    }
    
    // MARK: - Login with username and password to get cookies
    private static func _login(_ ctx:UPicCore, username: String, password: String, callback: @escaping ((_ errorMsg: String?, _ loginCookie: String?) -> Void)) {
        let loginUrl = "https://passport.weibo.cn/sso/login"
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/x-www-form-urlencoded"))
        headers.add(name: "Referer", value: loginUrl)
        
        let multipartFormData = MultipartFormData()
        multipartFormData.append(username.data(using: .utf8)!, withName: "username")
        multipartFormData.append(password.data(using: .utf8)!, withName: "password")
        
        var requestConfig = RequestConfig()
        requestConfig.url = loginUrl
        requestConfig.method = .post
        requestConfig.headers = headers
        requestConfig.multipartFormData = multipartFormData
        
        ctx.requester.upload(requestConfig).validate().responseString(completionHandler: { response in
            switch response.result {
            case .success(let value):
                guard let loginCookie = response.response?.headers.value(for: "Set-Cookie"), let model = LoginRetModel.deserialize(from: value) else {
                    callback(UploadError.invalidResponse.rawValue, nil)
                    return
                }
                
                if model.retcode == 20000000 {
                    callback(nil, loginCookie)
                } else {
                    callback(model.msg ?? UploadError.invalidResponse.rawValue, nil)
                }
                
            case .failure(let error):
                callback(error.localizedDescription, nil)
            }
        })
    }
    
    // MARK: - Parse image URL
    private static func parsePicPid(reponseString: String) -> String? {
        var regex = try! Regex("<.*?/>")
        var result = regex.replacingMatches(in: reponseString, with: "")
        regex = try! Regex("<(\\w+).*?>.*?</\\1>")
        result = regex.replacingMatches(in: result, with: "").trim()
        
        let picModel = WeiboPicModel.deserialize(from: result, designatedPath: "data.pics.pic_1")
        
        return picModel?.pid
    }
}

private struct WeiboPicModel: HandyJSON {
    var pid: String?
}
