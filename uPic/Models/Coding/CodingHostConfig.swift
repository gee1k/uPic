//
//  CodingHostConfig.swift
//  uPic
//
//  Created by 杨宇 on 2022/4/14.
//  Copyright © 2022 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers
class CodingHostConfig: HostConfig {
    dynamic var team: String = ""
    dynamic var project: String = ""
    dynamic var repoId: Int32 = 0
    dynamic var repo: String = ""
    dynamic var userId: Int32 = 0
    dynamic var branch: String = "master"
    dynamic var personalAccessToken: String = ""
    dynamic var saveKeyPath: String?
    
    override func displayName(key: String) -> String {
        switch key {
        case "team":
            return "CodingTeam".localized
        case "project":
            return "CodingProject".localized
        case "repoId":
            return "CodingRepoId".localized
        case "repo":
            return "Repo".localized
        case "userId":
            return "CodingUserId".localized
        case "branch":
            return "Branch".localized
        case "personalAccessToken":
            return "PersonalAccessToken".localized
        case "saveKeyPath":
            return "Save Key".localized
        default:
            return ""
        }
    }
    
    override func serialize() -> String {
        var dict = Dictionary<String, Any>()
        dict["team"] = self.team
        dict["project"] = self.project
        dict["repoId"] = self.repoId
        dict["repo"] = self.repo
        dict["userId"] = self.userId
        dict["branch"] = self.branch
        dict["personalAccessToken"] = self.personalAccessToken
        dict["saveKeyPath"] = self.saveKeyPath
        
        return JSON(dict).rawString()!
    }
    
    static func deserialize(str: String?) -> CodingHostConfig? {
        let config = CodingHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.team = json["team"].stringValue
        config.project = json["project"].stringValue
        config.repoId = json["repoId"].int32Value
        config.repo = json["repo"].stringValue
        config.userId = json["userId"].int32Value
        config.branch = json["branch"].stringValue
        config.personalAccessToken = json["personalAccessToken"].stringValue
        config.saveKeyPath = json["saveKeyPath"].stringValue
        return config
    }
}
