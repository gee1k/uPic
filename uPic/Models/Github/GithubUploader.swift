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

class GithubUploader: BaseUploader {
    static let shared = GithubUploader()
    static let fileExtensions: [String] = []

    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! GithubHostConfig

        let owner = config.owner
        let repo = config.repo
        let branch = config.branch
        let token = config.token
        let domain = config.domain

        let saveKeyPath = config.saveKeyPath

        guard let configuration = BaseUploaderUtil.getSaveConfigurationWithB64(fileUrl, fileData, saveKeyPath) else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        let retData = configuration["retData"] as? Data
        let fileBase64 = configuration["fileBase64"] as! String
        let fileName = configuration["fileName"] as! String
        let saveKey = configuration["saveKey"] as! String

        let url = GithubUtil.getUrl(owner: owner, repo: repo, filePath: saveKey)

        let parameters = GithubUtil.getRequestParameters(branch: branch, filePath: saveKey, b64Content: fileBase64)

        var headers = HTTPHeaders()
        headers.add(HTTPHeader.authorization("token \(token)"))
        headers.add(HTTPHeader.contentType("application/json"))
        headers.add(HTTPHeader.defaultUserAgent)

        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().uploadProgress { progress in
            super.progress(percent: progress.fractionCompleted)
        }.responseData(completionHandler: { response -> Void in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let errorMessage = json["message"].string {
                    super.faild(responseData: response.data, errorMsg: errorMessage)
                    return
                }
                if domain.isEmpty {
                    super.completed(url: json["content"]["download_url"].stringValue.urlDecoded(), retData, fileUrl, fileName)
                } else {
                    super.completed(url: "\(domain)/\(saveKey)", retData, fileUrl, fileName)
                }
            case .failure(let error):
                var errorMsg = error.localizedDescription

                if let data = response.data {
                    let json = JSON(data)
                    errorMsg = json["message"].stringValue
                    Logger.shared.error("upload image error: \(errorMsg)")

                    // If image name is duplicated, we will receive a 422 error and "sha\" wasn't supplied msg.
                    if !self.isImageNameDuplicatedError(json) {
                        super.faild(responseData: data, errorMsg: errorMsg)
                        return
                    }

                    let errMsg = errorMsg

                    Task {
                        do {
                            async let fileInfo = self.getGitHubFileInfo(url: url, token: token)
                            async let sha = retData?.githubSHAAsync() ?? ""
                            let (fileInfoJSON, shaValue) = await (try fileInfo, sha)

                            let fileSHA = fileInfoJSON["sha"].string
                            if shaValue == fileSHA {
                                Logger.shared.info("image has been uploaded, return download_url")
                                let url = domain.isEmpty ? fileInfoJSON["download_url"].stringValue : "\(domain)/\(saveKey)"
                                super.completed(url: url, retData, fileUrl, fileName)
                                return
                            }

                            Logger.shared.info("image name has been existed, re-load image with random name")

                            // If uploading image name has been existed, but sha hash is different, means they are different images, we need to re-upload the image. Use random file name.
                            self._upload(nil, fileData: retData, host: host)
                        } catch {
                            return super.faild(responseData: data, errorMsg: errMsg)
                        }
                    }
                }
            }
        })
    }

    func upload(_ fileUrl: URL, host: Host) {
        self._upload(fileUrl, fileData: nil, host: host)
    }

    func upload(_ fileData: Data, host: Host) {
        self._upload(nil, fileData: fileData, host: host)
    }

    /// Check if error status is 422 and message is "Invalid request.\n\n\"sha\" wasn't supplied.", that means the uploaded image name has been existed.
    func isImageNameDuplicatedError(_ json: JSON) -> Bool {
        if  json["status"].intValue == 422, json["message"].stringValue == "Invalid request.\n\n\"sha\" wasn't supplied." {
            return true
        }
        return false
    }

    /// Use AF await to get file JSON by github url GET method.
    func getGitHubFileInfo(url: String, token: String) async  throws -> JSON {
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.authorization("token \(token)"))
        headers.add(HTTPHeader.contentType("application/json"))
        headers.add(HTTPHeader.defaultUserAgent)

        let dataTask = AF.request(url, method: .get, headers: headers).serializingDecodable(JSON.self)
        return try await dataTask.value
    }
}
