//
//  CodingUtil.swift
//  uPic
//
//  Created by 杨宇 on 2022/4/14.
//  Copyright © 2022 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire

class CodingUtil {
    static func getUrl(team: String) -> String {
        // 接口来源参考 https://help.coding.net/openapi#2f96867ea5d085ee2649d29392a457b1 "https://{your-team}.coding.net/open-api?Action=CreateBinaryFiles"
        return "https://\(team).coding.net/open-api?Action=CreateBinaryFiles".urlEncoded()
    }
    
    static func getRequestParameters(userId: Int32, repoId: Int32, branch: String, filePath: String, b64Content: String) -> Parameters {
        var parameters = Parameters()
        parameters["Action"] = "CreateBinaryFiles"
        parameters["UserId"] = userId
        parameters["DepotId"] = repoId
        
        parameters["SrcRef"] = branch
        parameters["DestRef"] = branch
        
        parameters["Message"] = "⬆ Uploaded by uPic \n👉❤️ Powered by https://github.com/gee1k/uPic ❤️👈"
        parameters["LastCommitSha"] = ""
        
        var gitFile = Parameters()
        gitFile["Path"] = filePath.urlEncoded()
        gitFile["Content"] = b64Content
        
        parameters["GitFiles"] = [gitFile]
        
        return parameters;
    }
}
