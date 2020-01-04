//
//  GithubUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire

class GithubUtil {
    static func getUrl(owner: String, repo: String, filePath: String) -> String {
        return "https://api.github.com/repos/\(owner)/\(repo)/contents/\(filePath)".urlEncoded()
    }
    
    static func getRequestParameters(branch: String, filePath: String, b64Content: String) -> Parameters {
        var parameters = Parameters()
        parameters["branch"] = branch
        parameters["path"] = filePath.urlEncoded()
        parameters["content"] = b64Content
        parameters["message"] = "⬆ Uploaded by uPic \n👉❤️ Powered by https://github.com/gee1k/uPic ❤️👈"
        return parameters;
    }
}
