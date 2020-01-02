//
//  WeiboHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//
import Foundation
import SwiftyJSON

@objcMembers
class WeiboHostConfig: HostConfig {
    dynamic var username: String! = ""
    dynamic var password: String! = ""
    dynamic var cookieMode: String! = "0"
    dynamic var cookie: String! = ""
    dynamic var quality: String! = WeiboqQuality.large.rawValue
    // tva1.sinaimg.cn
    dynamic var domain: String! = "https://ws1.sinaimg.cn"

    override func displayName(key: String) -> String {
        switch key {
        case "username":
            return "Username".localized
        case "password":
            return "Password".localized
        case "cookieMode":
            return "Cookie Mode".localized
        case "cookie":
            return "Cookie".localized
        case "quality":
            return "Pic Quality".localized
        case "domain":
            return "Domain".localized
        default:
            return ""
        }
    }

    override func serialize() -> String {
        var dict = Dictionary<String, Any>()
        dict["username"] = self.username
        dict["password"] = self.password
        dict["cookieMode"] = self.cookieMode
        dict["cookie"] = self.cookie
        dict["quality"] = self.quality
        dict["domain"] = self.domain

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> WeiboHostConfig? {
        let config = WeiboHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.username = json["username"].stringValue
        config.password = json["password"].stringValue
        config.cookieMode = json["cookieMode"].stringValue
        config.cookie = json["cookie"].stringValue
        config.quality = json["quality"].stringValue
        if let domain = json["domain"].string {
            config.domain = domain
        }
        return config
    }
}
