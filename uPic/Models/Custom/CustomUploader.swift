//
//  CustomUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/27.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class CustomUploader: BaseUploader {

    static let shared = CustomUploader()
    static let fileExtensions: [String] = []

    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! CustomHostConfig

        let url = config.url!
        let method = config.method!
        let field = config.field!
        let domain = config.domain!
        
        let httpMethod = HTTPMethod(rawValue: method) 
        
        let saveKeyPath = config.saveKeyPath

        if url.isEmpty {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        guard let configuration = BaseUploaderUtil.getSaveConfiguration(fileUrl, fileData, saveKeyPath) else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        let retData = configuration["retData"] as? Data
        let fileName = configuration["fileName"] as! String
        let mimeType = configuration["mimeType"] as! String
        let saveKey = configuration["saveKey"] as! String

        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/x-www-form-urlencoded;charset=utf-8"))
        
        
        let otherVariables = ["saveKey": saveKey]

        if let headersStr = config.headers {
            let headersArr = CustomHostUtil.parseHeadersOrBodys(headersStr)
            for header in headersArr {
                if let key = header["key"] {
                    var value = header["value"] ?? ""
                    value = BaseUploaderUtil._parseVariables(value, fileName, otherVariables: otherVariables)

                    headers.add(HTTPHeader(name: key, value: value))
                }
            }
        }


        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            if let bodysStr = config.bodys {
                let bodysArr = CustomHostUtil.parseHeadersOrBodys(bodysStr)
                for body in bodysArr {
                    if let key = body["key"] {
                        var value = body["value"] ?? ""
                        value = BaseUploaderUtil._parseVariables(value, fileName, otherVariables: otherVariables)

                        multipartFormData.append(String(value).data(using: .utf8)!, withName: key)
                    }
                }
            }
            multipartFormData.append(saveKey.data(using: .utf8)!, withName: "key")
            if retData != nil {
                multipartFormData.append(retData!, withName: field, fileName: fileName, mimeType: mimeType)
            } else if fileUrl != nil {
                multipartFormData.append(fileUrl!, withName: field, fileName: fileName, mimeType: mimeType)
            }
        }


        AF.upload(multipartFormData: multipartFormDataGen, to: url, method: httpMethod, headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
            }.responseJSON(completionHandler: { response -> Void in
                debugPrint(response)
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var retUrl = CustomHostUtil.parseResultUrl(json, config.resultPath ?? "")
                if retUrl.isEmpty {
                    super.faild(errorMsg: "Did not get the file URL".localized)
                    return
                }
                if !domain.isEmpty {
                    retUrl = "\(domain)/\(retUrl)"
                }
                super.completed(url: "\(retUrl)\(config.suffix!)", retData, fileUrl, nil)
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
