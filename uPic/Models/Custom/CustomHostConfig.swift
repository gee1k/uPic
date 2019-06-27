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
    dynamic var url: String!
    dynamic var method: String! = RequestMethods.POST.rawValue
    dynamic var field: String!
    dynamic var extensions: String?
    dynamic var headers: String?
    dynamic var domain: String?
    dynamic var folder: String?
    dynamic var saveKey: String? = HostSaveKey.filename.rawValue

    override func displayName(key: String) -> String {
        switch key {
        case "url":
            return NSLocalizedString("host.url", comment: "url")
        case "method":
            return NSLocalizedString("host.method", comment: "method")
        case "field":
            return NSLocalizedString("host.field", comment: "field")
        case "extensions":
            return NSLocalizedString("host.extensions", comment: "extensions")
        case "headers":
            return NSLocalizedString("host.headers", comment: "headers")
        case "domain":
            return NSLocalizedString("host.domain", comment: "domain")
        case "folder":
            return NSLocalizedString("host.folder", comment: "folder")
        case "saveKey":
            return NSLocalizedString("host.saveKey", comment: "fileName")
        default:
            return ""
        }
    }

    override func serialize() -> String {
        var dict = Dictionary<String, Any>()
        dict["url"] = self.url
        dict["method"] = self.method
        dict["field"] = self.field
        dict["extensions"] = self.extensions
        dict["headers"] = self.headers
        dict["domain"] = self.domain
        dict["folder"] = self.folder
        dict["saveKey"] = self.saveKey

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> CustomHostConfig? {
        let config = CustomHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.url = json["url"].string
        config.method = json["method"].string
        config.field = json["field"].string
        config.extensions = json["extensions"].string
        config.headers = json["headers"].string
        config.domain = json["domain"].string
        config.folder = json["folder"].string
        config.saveKey = json["saveKey"].stringValue
        return config
    }
}
