//
//  MinioHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2020/4/12.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers
class MinioHostConfig: HostConfig {
    dynamic var region: String = "us-east-1"
    dynamic var url: String = ""
    dynamic var bucket: String = ""
    dynamic var accessKey: String = ""
    dynamic var secretKey: String = ""
    dynamic var domain: String = ""
    dynamic var saveKeyPath: String?
    dynamic var suffix: String = ""

    override func displayName(key: String) -> String {
        switch key {
        case "region":
            return "Region".localized
        case "url":
            return "Domain".localized
        case "bucket":
            return "Bucket".localized
        case "accessKey":
            return "Access Key".localized
        case "secretKey":
            return "Secret Key".localized
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
        dict["region"] = self.region
        dict["url"] = self.url
        dict["bucket"] = self.bucket
        dict["accessKey"] = self.accessKey
        dict["secretKey"] = self.secretKey
        dict["domain"] = self.domain
        dict["saveKeyPath"] = self.saveKeyPath
        dict["suffix"] = self.suffix

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> MinioHostConfig? {
        let config = MinioHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.region = json["region"].stringValue
        config.url = json["url"].stringValue
        config.bucket = json["bucket"].stringValue
        config.accessKey = json["accessKey"].stringValue
        config.secretKey = json["secretKey"].stringValue
        config.domain = json["domain"].stringValue
        config.saveKeyPath = json["saveKeyPath"].string
        config.suffix = json["suffix"].stringValue
        return config
    }
}
