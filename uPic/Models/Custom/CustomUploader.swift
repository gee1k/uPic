//
//  CustomUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/27.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyXMLParser

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
        if fileUrl != nil {
            fileName = "\(hostSaveKey.getFileName(filename: fileUrl!.lastPathComponent.deletingPathExtension)).\(fileUrl!.pathExtension)"
            mimeType = Util.getMimeType(pathExtension: fileUrl!.pathExtension)
        } else {
            // MARK: 处理截图之类的图片，生成一个文件名
            fileName = "\(hostSaveKey.getFileName()).png"
            mimeType = Util.getMimeType(pathExtension: "png")
        }

        var key = fileName
        if (config.folder != nil && config.folder!.count > 0) {
            key = "\(config.folder!)/\(key)"
        }

        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/x-www-form-urlencoded;charset=utf-8"))
        if let headersStr = config.headers {
            let headersArr = headersStr.split(separator: Character("&"))
            for headerSr in headersArr {
                let headerArr = headerSr.split(separator: Character("="))
                if headerArr.count < 2 {
                    continue
                }
                var value = String(headerArr[1])
                switch value {
                case "{filename}":
                    value = fileName
                    break
                case "{path}":
                    value = key
                    break
                case "{folder}":
                    value = config.folder ?? ""
                    break
                default:
                    break
                }
                headers.add(HTTPHeader(name: String(headerArr[0]), value: value))
            }
        }
        
        func multipartFormDataGen(multipartFormData: MultipartFormData) {
            multipartFormData.append(key.data(using: .utf8)!, withName: "key")
            
            if let extensionsStr = config.extensions {
                let extensionsArr = extensionsStr.split(separator: Character("&"))
                for extensions in extensionsArr {
                    let extensionArr = extensions.split(separator: Character("="))
                    if extensionArr.count < 2 {
                        continue
                    }
                    
                    var value = String(extensionArr[1])
                    switch value {
                    case "{filename}":
                        value = fileName
                        break
                    case "{path}":
                        value = key
                        break
                    case "{folder}":
                        value = config.folder ?? ""
                        break
                    default:
                        break
                    }
                    multipartFormData.append(String(value).data(using: .utf8)!, withName: String(extensionArr[0]))
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
        }.response(completionHandler: { response -> Void in
            switch response.result {
            case .success(_):
                super.completed(url: "\(domain)/\(key)")
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
