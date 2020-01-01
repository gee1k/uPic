//
//  SmmsHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

import Foundation
import SwiftyJSON

@objcMembers
class SmmsHostConfig: HostConfig {
    dynamic var version: String! = SmmsVersion.v1.rawValue
    dynamic var token: String?

    override func displayName(key: String) -> String {
        switch key {
        case "version":
            return "Version".localized
        case "token":
            return "Token".localized
        default:
            return ""
        }
    }

    override func serialize() -> String {
        var dict = Dictionary<String, Any>()
        dict["version"] = self.version
        dict["token"] = self.token

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> SmmsHostConfig? {
        let config = SmmsHostConfig()
        guard let str = str else {
            return config
        }
        
        let data = str.data(using: String.Encoding.utf8)
        if let json = try? JSON(data: data!) {
            config.version = json["version"].stringValue
            config.token = json["token"].stringValue
        }
        
        return config
    }
}
