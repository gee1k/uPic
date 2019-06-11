//
//  SmmsPic.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/8.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Alamofire

class SmmsPic {
    static let share = SmmsPic()
    
    static let imageTypes = ["png", "jpg", "tiff", "jpeg", "gif"]
    
    enum PicUrl: String {
        case upload = "https://sm.ms/api/upload"
        case clear = "https://sm.ms/api/clear"
    }
    
    private func _upload(_ multipartFormData: @escaping ((MultipartFormData) -> Void), callback: @escaping ((JSON) -> Void)) {
        NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.start.title", comment: "开始上传通知标题"), subTitle: NSLocalizedString("upload.notification.start.subtitle", comment: "开始上传通知副标题"), body: "")
        AF.upload(multipartFormData: multipartFormData, to: PicUrl.upload.rawValue, method: HTTPMethod.post).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                callback(json)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func upload(_ filePath: URL, callback: @escaping ((JSON) -> Void)) {
        self._upload({ (multipartFormData:MultipartFormData) in
            multipartFormData.append(filePath, withName: "smfile")
        }, callback: callback)
    }
    
    func upload(_ imgData: Data, callback: @escaping ((JSON) -> Void)) {
        self._upload({ (multipartFormData:MultipartFormData) in
            multipartFormData.append(imgData, withName: "smfile", fileName: "smfile.png",
                                                                          mimeType: "image/png")
        }, callback: callback)
    }
    
    func clearHistory(callback: @escaping ((JSON) -> Void)) {
        AF.request(PicUrl.clear.rawValue).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                callback(json)
            case .failure(let error):
                print(error)
            }
        }
    }
}
