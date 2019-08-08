//
//  GithubUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GiteeUploader: BaseUploader {
    static let shared = GiteeUploader()
    static let fileExtensions: [String] = []
    
    func _upload(_ fileUrl: URL?, fileData: Data?) {
        guard let host = ConfigManager.shared.getDefaultHost(), let data = host.data else {
            super.faild(errorMsg: NSLocalizedString("bad-host-config", comment: "bad host config"))
            return
        }
        
        super.start()
        
        let config = data as! GiteeHostConfig
        
        let owner = config.owner!
        let repo = config.repo!
        let branch = config.branch!
        let token = config.token!
        let hostSaveKey = (config.saveKey != nil ? HostSaveKey(rawValue: config.saveKey!) : HostSaveKey.dateFilename)!
        let domain = config.domain
        
        var fileName = ""
        var fileBase64 = ""
        
        if let fileUrl = fileUrl {
            fileName = "\(hostSaveKey.getFileName(filename: fileUrl.lastPathComponent.deletingPathExtension)).\(fileUrl.pathExtension)"
            
            do {
                var data = try Data(contentsOf: fileUrl)
                data = BaseUploaderUtil.compressImage(data)
                fileBase64 = data.toBase64()
            } catch {
                super.faild(errorMsg: "Invalid file")
                return
            }
        } else if let fileData = fileData {
            // MARK: 处理截图之类的图片，生成一个文件名
            let fileType = fileData.contentType() ?? "png"
            fileName = "\(hostSaveKey.getFileName()).\(fileType)"
            
            let retData = BaseUploaderUtil.compressImage(fileData)
            fileBase64 = retData.toBase64()
        } else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        
        var filePath = fileName
        if (config.folder != nil && !config.folder!.isEmpty) {
            filePath = "\(config.folder!)/\(filePath)"
        }
        
        
        let url = GiteeUtil.getUrl(owner: owner, repo: repo, filePath: filePath)

        let parameters = GiteeUtil.getRequestParameters(token: token, branch: branch, filePath: filePath, b64Content: fileBase64)
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/json"))
        headers.add(name: "User-Agent", value: "Macos/uPic")
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
            }.responseJSON(completionHandler: { response -> Void in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let errorMessage = json["message"].string {
                        super.faild(errorMsg: errorMessage)
                        return
                    }
                    if domain == nil || domain!.isEmpty {
                        super.completed(url: json["content"]["download_url"].stringValue.urlDecoded())
                    } else {
                        super.completed(url: "\(domain!)/\(filePath)")
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
