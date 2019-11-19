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

    static let shared = SmmsUploader()

    static let fileExtensions: [String] = ["jpeg", "jpg", "png", "gif", "bmp"]
    
    // limit 5M
    static let limitSize: UInt64 = 5 * 1024 * 1024
    
    let url = "https://sm.ms/api/upload"

    func _upload(_ fileUrl: URL?, fileData: Data?) {
        super.start()

        var retData = fileData
        var fileName = ""
        var mimeType = ""
        if let fileUrl = fileUrl {
            fileName = fileUrl.lastPathComponent
            mimeType = Util.getMimeType(pathExtension: fileUrl.pathExtension)
            retData = BaseUploaderUtil.compressImage(fileUrl)
        } else if let fileData = fileData {
            retData = BaseUploaderUtil.compressImage(fileData)
            // 处理截图之类的图片，生成一个文件名
            let fileType = fileData.contentType() ?? "png"
            fileName = "smms.\(fileType)"
            mimeType = Util.getMimeType(pathExtension: fileType)
        } else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            if retData != nil {
                multipartFormData.append(retData!, withName: "smfile", fileName: fileName, mimeType: mimeType)
            } else if fileUrl != nil {
                multipartFormData.append(fileUrl!, withName: "smfile", fileName: fileName, mimeType: mimeType)
            }
        }

        AF.upload(multipartFormData: multipartFormDataGen, to: url, method: HTTPMethod.post).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
        }.responseJSON(completionHandler: { response -> Void in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let success = json["success"].intValue
                if 0 == success {
                    let msg = json["message"].stringValue
                    super.faild(errorMsg: msg)
                } else {
                    let data = json["data"]
                    let url = data["url"].stringValue
                    super.completed(url: url)
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
