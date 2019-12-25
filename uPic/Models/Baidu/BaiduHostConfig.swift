//
//  BaiduHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/11/19.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers
class BaiduHostConfig: HostConfig {
    dynamic var region: String! = ""
    dynamic var bucket: String! = ""
    dynamic var accessKey: String! = ""
    dynamic var secretKey: String! = ""
    dynamic var domain: String! = ""
    dynamic var saveKeyPath: String?
    dynamic var suffix: String! = ""
    
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
        dict["bucket"] = self.bucket
        dict["accessKey"] = self.accessKey
        dict["secretKey"] = self.secretKey
        dict["domain"] = self.domain
        dict["saveKeyPath"] = self.saveKeyPath
        dict["suffix"] = self.suffix
        
        return JSON(dict).rawString()!
    }
    
    static func deserialize(str: String?) -> BaiduHostConfig? {
        let config = BaiduHostConfig()
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
        config.saveKeyPath = json["saveKeyPath"].stringValue
        config.suffix = json["suffix"].stringValue
        return config
    }
}
