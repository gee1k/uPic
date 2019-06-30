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

    override func displayName(key: String) -> String {
        switch key {
        case "bucket":
            return NSLocalizedString("host.bucket", comment: "bucket")
        case "operatorName":
            return NSLocalizedString("host.operator", comment: "operator")
        case "password":
            return NSLocalizedString("host.password", comment: "password")
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
        dict["bucket"] = self.bucket
        dict["operatorName"] = self.operatorName
        dict["password"] = self.password
        dict["domain"] = self.domain
        dict["folder"] = self.folder
        dict["saveKey"] = self.saveKey

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
        return config
    }
}
