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

    override func displayName(key: String) -> String {
        switch key {
        case "region":
            return NSLocalizedString("host.region", comment: "region")
        case "bucket":
            return NSLocalizedString("host.bucket", comment: "bucket")
        case "secretId":
            return NSLocalizedString("host.secretId", comment: "secretId")
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
        dict["secretId"] = self.secretId
        dict["secretKey"] = self.secretKey
        dict["domain"] = self.domain
        dict["folder"] = self.folder
        dict["saveKey"] = self.saveKey

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> TencentHostConfig? {
        let config = TencentHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.region = json["region"].string
        config.bucket = json["bucket"].string
        config.secretId = json["secretId"].string
        config.secretKey = json["secretKey"].string
        config.domain = json["domain"].string
        config.folder = json["folder"].string
        config.saveKey = json["saveKey"].stringValue
        return config
    }
}
