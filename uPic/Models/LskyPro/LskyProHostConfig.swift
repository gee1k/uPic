//
//  LskyHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2020/2/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//
import Foundation
import SwiftyJSON

@objcMembers
class LskyProHostConfig: HostConfig {
    dynamic var email: String = ""
    dynamic var password: String = ""
    dynamic var isAnonymous: Bool = true
    dynamic var domain: String = "https://pic.iqy.ink"

    override func displayName(key: String) -> String {
        switch key {
        case "email":
            return "Email".localized
        case "password":
            return "Password".localized
        case "isAnonymous":
            return "Anonymous".localized
        case "domain":
            return "Domain".localized
        default:
            return ""
        }
    }

    override func serialize() -> String {
        var dict = Dictionary<String, Any>()
        dict["email"] = self.email
        dict["password"] = self.password
        dict["isAnonymous"] = self.isAnonymous
        dict["domain"] = self.domain

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> LskyProHostConfig? {
        let config = LskyProHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.email = json["email"].stringValue
        config.password = json["password"].stringValue
        config.isAnonymous = json["isAnonymous"].boolValue
        config.domain = json["domain"].stringValue
        return config
    }
}
