//
//  UpYunHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/16.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers
class UpYunHostConfig: HostConfig {
    dynamic var bucket: String! = ""
    dynamic var operatorName: String! = ""
    dynamic var password: String! = ""
    dynamic var domain: String! = ""
    dynamic var saveKeyPath: String?
    dynamic var suffix: String! = ""

    override func displayName(key: String) -> String {
        switch key {
        case "bucket":
            return "Bucket".localized
        case "operatorName":
            return "Operator".localized
        case "password":
            return "Password".localized
        case "domain":
            return "Domain".localized
        case "saveKeyPath":
            return "Save Key".localized
        case "suffix":
            return "URL suffix".localized
        default:
            return ""
        }
    }
    
    override func serialize() -> String {
        var dict = Dictionary<String, Any>()
        dict["bucket"] = self.bucket
        dict["operatorName"] = self.operatorName
        dict["password"] = self.password
        dict["domain"] = self.domain
        dict["saveKeyPath"] = self.saveKeyPath
        dict["suffix"] = self.suffix

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> UpYunHostConfig? {
        let config = UpYunHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.bucket = json["bucket"].stringValue
        config.operatorName = json["operatorName"].stringValue
        config.password = json["password"].stringValue
        config.domain = json["domain"].stringValue
        config.saveKeyPath = json["saveKeyPath"].stringValue
        config.suffix = json["suffix"].stringValue
        return config
    }
}
