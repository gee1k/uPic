//
//  TencentHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers
class TencentHostConfig: HostConfig {
    dynamic var region: String?
    dynamic var bucket: String?
    dynamic var secretId: String?
    dynamic var secretKey: String?
    dynamic var domain: String?
    dynamic var folder: String?
    dynamic var saveKey: String? = HostSaveKey.filename.rawValue
    dynamic var suffix: String?

    override func displayName(key: String) -> String {
        switch key {
        case "region":
            return NSLocalizedString("host.field.region", comment: "region")
        case "bucket":
            return NSLocalizedString("host.field.bucket", comment: "bucket")
        case "secretId":
            return NSLocalizedString("host.field.secretId", comment: "secretId")
        case "secretKey":
            return NSLocalizedString("host.field.secretKey", comment: "secretKey")
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
        dict["region"] = self.region
        dict["bucket"] = self.bucket
        dict["secretId"] = self.secretId
        dict["secretKey"] = self.secretKey
        dict["domain"] = self.domain
        dict["folder"] = self.folder
        dict["saveKey"] = self.saveKey
        dict["suffix"] = self.suffix

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> TencentHostConfig? {
        let config = TencentHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.region = json["region"].stringValue
        config.bucket = json["bucket"].stringValue
        config.secretId = json["secretId"].stringValue
        config.secretKey = json["secretKey"].stringValue
        config.domain = json["domain"].stringValue
        config.folder = json["folder"].stringValue
        config.saveKey = json["saveKey"].stringValue
        config.suffix = json["suffix"].stringValue
        return config
    }
}
