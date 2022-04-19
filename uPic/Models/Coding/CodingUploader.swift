//
//  CodingUploader.swift
//  uPic
//
//  Created by 杨宇 on 2022/4/14.
//  Copyright © 2022 Svend Jin. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import SwiftyJSON

class CodingUploader: BaseUploader {
    static let shared = CodingUploader()
    static let fileExtensions: [String] = []
    
    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }
        
        super.start()
        
        let config = data as! CodingHostConfig
        
        let team = config.team
        let project = config.project
        let userId = config.userId
        let repoId = config.repoId
        let repo = config.repo
        let branch = config.branch
        let token = config.personalAccessToken
        let saveKeyPath = config.saveKeyPath
        
        guard let configuration = BaseUploaderUtil.getSaveConfigurationWithB64(fileUrl, fileData, saveKeyPath) else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        let retData = configuration["retData"] as? Data
        let fileBase64 = configuration["fileBase64"] as! String
        let fileName = configuration["fileName"] as! String
        let saveKey = configuration["saveKey"] as! String
        print("retData: " , retData)
        print("fileName: " , fileName)
        print("saveKey: " , saveKey)
        let url = CodingUtil.getUrl(team: team)
        
        let parameters = CodingUtil.getRequestParameters(userId: userId, repoId: repoId, branch: branch, filePath: saveKey, b64Content: fileBase64)
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.contentType("application/json"))
        headers.add(name: "User-Agent", value: "Macos/uPic")
        headers.add(name: "Authorization", value: "token " + token)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
            }.responseJSON(completionHandler: { response -> Void in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    if let errorMessage = json["Response"]["Error"]["Message"].string {
                        super.faild(errorMsg: errorMessage)
                        print("Error: " + errorMessage)
                        return
                    }
                    super.completed(url: "https://\(team).coding.net/p/\(project)/d/\(repo)/git/raw/\(branch)/\(saveKey)", retData, fileUrl, fileName)
                case .failure(let error):
                    var errorMsg = error.localizedDescription
                    if let data = response.data {
                        let json = JSON(data)
                        errorMsg = json["message"].stringValue
                    }
                    super.faild(errorMsg: errorMsg)
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
