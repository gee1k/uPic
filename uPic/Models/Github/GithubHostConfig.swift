//
//  GithubHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers
class GithubHostConfig: HostConfig {
    dynamic var owner: String! = ""
    dynamic var repo: String! = ""
    dynamic var branch: String! = "master"
    dynamic var token: String! = ""
    dynamic var domain: String! = ""
    dynamic var saveKeyPath: String?
    dynamic var useCdn: String! = "0"
    
    override func displayName(key: String) -> String {
        switch key {
        case "owner":
            return "Owner".localized
        case "repo":
            return "Repo".localized
        case "branch":
            return "Branch".localized
        case "token":
            return "Token".localized
        case "domain":
            return "Domain".localized
        case "saveKeyPath":
            return "Save Key".localized
        case "useCdn":
            return "Use CDN".localized
        default:
            return ""
        }
    }
    
    override func serialize() -> String {
        var dict = Dictionary<String, Any>()
        dict["owner"] = self.owner
        dict["repo"] = self.repo
        dict["branch"] = self.branch
        dict["token"] = self.token
        dict["domain"] = self.domain
        dict["saveKeyPath"] = self.saveKeyPath
        dict["useCdn"] = self.useCdn
        
        return JSON(dict).rawString()!
    }
    
    static func deserialize(str: String?) -> GithubHostConfig? {
        let config = GithubHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.owner = json["owner"].stringValue
        config.repo = json["repo"].stringValue
        config.branch = json["branch"].stringValue
        config.token = json["token"].stringValue
        config.domain = json["domain"].stringValue
        config.saveKeyPath = json["saveKeyPath"].stringValue
        config.useCdn = json["useCdn"].stringValue
        return config
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        super.controlTextDidChange(obj)
        if self.useCdn != "1" {
            return
        }
        let keys = ["owner", "repo", "branch"]
        if let textField = obj.object as? NSTextField, let key = textField.identifier?.rawValue, keys.contains(key) {
            PreferencesNotifier.postNotification(.githubCDNAutoComplete)
        }
    }
}
