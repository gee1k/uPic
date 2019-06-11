//
//  SmmsUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/10.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Alamofire

class SmmsUploader: BaseUploader {
    
    static let share = SmmsUploader()
    
    let url = "https://sm.ms/api/upload"
    
    static let imageTypes = ["png", "jpg", "tiff", "jpeg", "gif"]
    
    func _upload(_ multipartFormData: @escaping ((MultipartFormData) -> Void), callback: @escaping ((String, Error?) -> Void)) {
        super._upload(url, multipartFormData: multipartFormData, callback: { response -> Void in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let code = json["code"]
                if "error" == code {
                    let msg = json["msg"].stringValue
                    debugPrint(msg)
                    callback("", UploaderError(message: msg))
                } else {
                    let data = json["data"]
                    let url = data["url"].stringValue
                    callback(url, nil)
                }
            case .failure(let error):
                callback("", error)
            }
        })
    }
    
    func upload(_ fileUrl: URL, callback: @escaping ((String, Error?) -> Void)) {
        self._upload({ (multipartFormData:MultipartFormData) in
            multipartFormData.append(fileUrl, withName: "smfile")
        }, callback: callback)
    }
    
    func upload(_ imgData: Data, callback: @escaping ((String, Error?) -> Void)) {
        self._upload({ (multipartFormData:MultipartFormData) in
            multipartFormData.append(imgData, withName: "smfile", fileName: "smfile.png",
                                     mimeType: "image/png")
        }, callback: callback)
    }
}
