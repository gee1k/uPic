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

    let url = "https://sm.ms/api/upload"

    static let fileExtensions: [String] = ["jpeg", "jpg", "png", "gif", "bmp"]

    func _upload(_ multipartFormData: @escaping ((MultipartFormData) -> Void)) {
        super.start()

        AF.upload(multipartFormData: multipartFormData, to: url, method: HTTPMethod.post).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
        }.responseJSON(completionHandler: { response -> Void in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let code = json["code"]
                if "error" == code {
                    let msg = json["msg"].stringValue
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
        self._upload({ (multipartFormData: MultipartFormData) in
            
            let retData = BaseUploaderUtil.compressImage(fileUrl)
            if retData != nil {
                multipartFormData.append(retData!, withName: "smfile")
            } else {
                multipartFormData.append(fileUrl, withName: "smfile")
            }
            
        })
    }

    func upload(_ imgData: Data) {
        let retData = BaseUploaderUtil.compressImage(imgData)
        self._upload({ (multipartFormData: MultipartFormData) in
            multipartFormData.append(retData, withName: "smfile", fileName: "smfile.png")
        })
    }
}
