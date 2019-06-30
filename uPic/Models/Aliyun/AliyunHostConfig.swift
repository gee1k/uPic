//
//  AliyunHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers
class AliyunHostConfig: HostConfig {
    dynamic var region: String!
    dynamic var bucket: String!
    dynamic var accessKey: String!
    dynamic var secretKey: String!
    dynamic var domain: String!
    dynamic var folder: String?
    dynamic var saveKey: String! = HostSaveKey.filename.rawValue

    override func displayName(key: String) -> String {
        switch key {
        case "region":
            return NSLocalizedString("host.region", comment: "region")
        case "bucket":
            return NSLocalizedString("host.bucket", comment: "bucket")
        case "accessKey":
            return NSLocalizedString("host.accessKey", comment: "accessKey")
        case "secretKey":
            return NSLocalizedString("host.secretKey", comment: "secretKey")
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
        dict["region"] = self.region
        dict["bucket"] = self.bucket
        dict["accessKey"] = self.accessKey
        dict["secretKey"] = self.secretKey
        dict["domain"] = self.domain
        dict["folder"] = self.folder
        dict["saveKey"] = self.saveKey

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> AliyunHostConfig? {
        let config = AliyunHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.region = json["region"].stringValue
        config.bucket = json["bucket"].stringValue
        config.accessKey = json["accessKey"].stringValue
        config.secretKey = json["secretKey"].stringValue
        config.domain = json["domain"].stringValue
        config.folder = json["folder"].stringValue
        config.saveKey = json["saveKey"].stringValue
        return config
    }
}
