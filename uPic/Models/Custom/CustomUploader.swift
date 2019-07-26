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

    func _upload(_ fileUrl: URL?, fileData: Data?) {
        guard let host = ConfigManager.shared.getDefaultHost(), let data = host.data else {
            super.faild(errorMsg: NSLocalizedString("bad-host-config", comment: "bad host config"))
            return
        }

        super.start()

        let config = data as! CustomHostConfig

        let url = config.url!
        let method = config.method!
        let field = config.field!
        let hostSaveKey = HostSaveKey(rawValue: config.saveKey!)!
        let domain = config.domain!

        let httpMethod = HTTPMethod(rawValue: method) ?? HTTPMethod.post


        if url.isEmpty {
            super.faild(errorMsg: NSLocalizedString("bad-host-config", comment: "bad host config"))
            return
        }

        var fileName = ""
        var mimeType = ""
        if let fileUrl = fileUrl {
            fileName = "\(hostSaveKey.getFileName(filename: fileUrl.lastPathComponent.deletingPathExtension)).\(fileUrl.pathExtension)"
            mimeType = Util.getMimeType(pathExtension: fileUrl.pathExtension)
        } else if let fileData = fileData {
            // MARK: 处理截图之类的图片，生成一个文件名
            fileName = "\(hostSaveKey.getFileName()).png"
            mimeType = Util.getMimeType(pathExtension: "png")
        } else {
            super.faild(errorMsg: "Invalid file")
            return
        }

        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/x-www-form-urlencoded;charset=utf-8"))

        if let headersStr = config.headers {
            let headersArr = CustomHostUtil.parseHeadersOrBodys(headersStr)
            for header in headersArr {
                if let key = header["key"] {
                    var value = header["value"] ?? ""
                    if value == "{filename}" {
                        value = fileName
                    }

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
                        if value == "{filename}" {
                            value = fileName
                        }

                        multipartFormData.append(String(value).data(using: .utf8)!, withName: key)
                    }
                }
            }

            if fileUrl != nil {
                multipartFormData.append(fileUrl!, withName: field, fileName: fileName, mimeType: mimeType)
            } else {
                multipartFormData.append(fileData!, withName: field, fileName: fileName, mimeType: mimeType)
            }
        }


        AF.upload(multipartFormData: multipartFormDataGen, to: url, method: httpMethod, headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
            }.responseJSON(completionHandler: { response -> Void in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var retUrl = CustomHostUtil.parseResultUrl(json, config.resultPath ?? "")
                if !domain.isEmpty {
                    retUrl = "\(domain)/\(retUrl)"
                }
                super.completed(url: retUrl)
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
