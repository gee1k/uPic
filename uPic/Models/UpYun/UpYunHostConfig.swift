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
    dynamic var bucketName: String?
    dynamic var operatorName: String?
    dynamic var password: String?
    dynamic var domain: String?
    dynamic var folder: String?
    dynamic var saveKey: String? = HostSaveKey.filename.rawValue
    
    override func displayName(key: String) -> String {
        switch key {
        case "bucketName":
            return "Bucket"
        case "operatorName":
            return "操作员"
        case "password":
            return "密码"
        case "domain":
            return "域名"
        case "folder":
            return "文件夹"
        case "saveKey":
            return "文件名"
        default:
            return ""
        }
    }
    
    override func serialize() -> String {
        var dict = Dictionary<String, Any>()
        dict["bucketName"] = self.bucketName
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
        config.bucketName = json["bucketName"].string
        config.operatorName = json["operatorName"].string
        config.password = json["password"].string
        config.domain = json["domain"].string
        config.folder = json["folder"].string
        config.saveKey = json["saveKey"].stringValue
        return config
    }
}
