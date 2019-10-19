//
//  AmazonS3HostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/7/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers
class AmazonS3HostConfig: HostConfig {
    dynamic var region: String!
    dynamic var bucket: String!
    dynamic var accessKey: String!
    dynamic var secretKey: String!
    dynamic var domain: String!
    dynamic var folder: String?
    dynamic var saveKey: String! = HostSaveKey.filename.rawValue
    dynamic var suffix: String?

    override func displayName(key: String) -> String {
        switch key {
        case "region":
            return "Region".localized
        case "bucket":
            return "Bucket".localized
        case "accessKey":
            return "Access Key".localized
        case "secretKey":
            return "Secret Key".localized
        case "domain":
            return "Domain".localized
        case "folder":
            return "Folder".localized
        case "saveKey":
            return "File Name".localized
        case "suffix":
            return "URL suffix".localized
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
        dict["suffix"] = self.suffix

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> AmazonS3HostConfig? {
        let config = AmazonS3HostConfig()
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
        config.suffix = json["suffix"].stringValue
        return config
    }
}
