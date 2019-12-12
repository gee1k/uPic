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

    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        super.start()

        guard let configuration = BaseUploaderUtil.getSaveConfiguration(fileUrl, fileData, nil) else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        let retData = configuration["retData"] as? Data
        let fileName = configuration["fileName"] as! String
        let mimeType = configuration["mimeType"] as! String
        
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
                    super.completed(url: url, fileData?.toBase64(), fileUrl, nil)
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
