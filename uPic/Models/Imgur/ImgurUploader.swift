//
//  ImgurUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Alamofire

class ImgurUploader: BaseUploader {

    static let shared = ImgurUploader()

    static let fileExtensions: [String] = ["jpg", "jpeg", "png", "gif", "apng", "tiff", "tif", "bmp", "xcf", "webp", "mp4", "mov", "avi", "webm"]
    
    // limit 10M
    static let limitSize: UInt64 = 10 * 1024 * 1024
    
    let url = "https://api.imgur.com/3/image";

    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! ImgurHostConfig


        let clientId = config.clientId!

        guard let configuration = BaseUploaderUtil.getSaveConfigurationWithB64(fileUrl, fileData, nil) else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        let retData = configuration["retData"] as? Data
        let fileBase64 = configuration["fileBase64"] as! String
        let fileName = configuration["fileName"] as! String

        var headers = HTTPHeaders()
        headers.add(HTTPHeader.authorization("Client-ID \(clientId)"))
        headers.add(HTTPHeader.contentType("multipart/form-data"))
        headers.add(name: "User-Agent", value: "Macos/uPic")
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            multipartFormData.append("base64".data(using: .utf8)!, withName: "type")
            multipartFormData.append(fileName.data(using: .utf8)!, withName: "name")
            multipartFormData.append(fileBase64.data(using: .utf8)!, withName: "image")
        }
        
        
        AF.upload(multipartFormData: multipartFormDataGen, to: url, headers: headers).uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
            }.responseJSON(completionHandler: { response -> Void in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if json["success"].boolValue {
                        super.completed(url: json["data"]["link"].stringValue.urlDecoded(), retData, fileUrl, fileName)
                    } else {
                        let error = json["data"]["error"]
                        let errorMsg = error.string ?? error["message"].stringValue
                        super.faild(errorMsg: errorMsg)
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
