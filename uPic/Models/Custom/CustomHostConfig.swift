//
//  CustomHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/27.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers
class CustomHostConfig: HostConfig {
    dynamic var url: String! = ""
    dynamic var method: String! = RequestMethods.POST.rawValue
    dynamic var field: String! = ""
    dynamic var bodys: String?
    dynamic var headers: String?
    dynamic var resultPath: String?
    dynamic var domain: String! = ""
    dynamic var saveKeyPath: String?
    dynamic var suffix: String! = ""

    override func displayName(key: String) -> String {
        switch key {
        case "url":
            return "API URL".localized
        case "method":
            return "Method".localized
        case "field":
            return "File Field".localized
        case "bodys":
            return "Bodys".localized
        case "headers":
            return "Headers".localized
        case "resultPath":
            return "URL Path".localized
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
        dict["url"] = self.url
        dict["method"] = self.method
        dict["field"] = self.field
        dict["bodys"] = self.bodys
        dict["headers"] = self.headers
        dict["resultPath"] = self.resultPath
        dict["domain"] = self.domain
        dict["saveKeyPath"] = self.saveKeyPath
        dict["suffix"] = self.suffix

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> CustomHostConfig? {
        let config = CustomHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.url = json["url"].stringValue
        config.method = json["method"].stringValue
        config.field = json["field"].stringValue
        config.bodys = json["bodys"].stringValue
        config.headers = json["headers"].stringValue
        config.resultPath = json["resultPath"].stringValue
        config.domain = json["domain"].stringValue
        config.saveKeyPath = json["saveKeyPath"].stringValue
        config.suffix = json["suffix"].stringValue
        return config
    }
}
