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
    dynamic var resultPath: String?
    dynamic var domain: String?
    dynamic var saveKey: String? = HostSaveKey.filename.rawValue

    override func displayName(key: String) -> String {
        switch key {
        case "url":
            return NSLocalizedString("host.field.url", comment: "url")
        case "method":
            return NSLocalizedString("host.field.method", comment: "method")
        case "field":
            return NSLocalizedString("host.field.field", comment: "field")
        case "extensions":
            return NSLocalizedString("host.field.extensions", comment: "extensions")
        case "headers":
            return NSLocalizedString("host.field.headers", comment: "headers")
        case "resultPath":
            return NSLocalizedString("host.field.resultPath", comment: "resultPath")
        case "domain":
            return NSLocalizedString("host.field.domain", comment: "domain")
        case "saveKey":
            return NSLocalizedString("host.field.saveKey", comment: "fileName")
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
        dict["resultPath"] = self.resultPath
        dict["domain"] = self.domain
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
        config.url = json["url"].stringValue
        config.method = json["method"].stringValue
        config.field = json["field"].stringValue
        config.extensions = json["extensions"].stringValue
        config.headers = json["headers"].stringValue
        config.resultPath = json["resultPath"].stringValue
        config.domain = json["domain"].stringValue
        config.saveKey = json["saveKey"].stringValue
        return config
    }
}
