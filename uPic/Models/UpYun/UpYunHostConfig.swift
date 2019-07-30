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
    dynamic var bucket: String?
    dynamic var operatorName: String?
    dynamic var password: String?
    dynamic var domain: String?
    dynamic var folder: String?
    dynamic var saveKey: String? = HostSaveKey.filename.rawValue
    dynamic var suffix: String?

    override func displayName(key: String) -> String {
        switch key {
        case "bucket":
            return NSLocalizedString("host.field.bucket", comment: "bucket")
        case "operatorName":
            return NSLocalizedString("host.field.operator", comment: "operator")
        case "password":
            return NSLocalizedString("host.field.password", comment: "password")
        case "domain":
            return NSLocalizedString("host.field.domain", comment: "domain")
        case "folder":
            return NSLocalizedString("host.field.folder", comment: "folder")
        case "saveKey":
            return NSLocalizedString("host.field.saveKey", comment: "fileName")
        case "suffix":
            return NSLocalizedString("host.field.suffix", comment: "suffix")
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
        dict["folder"] = self.folder
        dict["saveKey"] = self.saveKey
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
        config.folder = json["folder"].stringValue
        config.saveKey = json["saveKey"].stringValue
        config.suffix = json["suffix"].stringValue
        return config
    }
}
