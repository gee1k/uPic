//
//  BaseUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/10.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Alamofire

class BaseUploader {
    
    struct UploaderError: Error {
        let message: String
    }
    
    func _upload(_ url:String, multipartFormData: @escaping ((MultipartFormData) -> Void), callback: @escaping ((DataResponse<Any>) -> Void)) {
        NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.start.title", comment: "开始上传通知标题"), subTitle: NSLocalizedString("upload.notification.start.subtitle", comment: "开始上传通知副标题"), body: "")
        AF.upload(multipartFormData: multipartFormData, to: url, method: HTTPMethod.post).validate().responseJSON(completionHandler: callback)
        
    }
}
