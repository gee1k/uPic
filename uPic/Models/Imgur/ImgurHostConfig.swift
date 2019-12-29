//
//  ImgurHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/8/17.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

@objcMembers
class ImgurHostConfig: HostConfig {
    dynamic var clientId: String! = ""

    override func displayName(key: String) -> String {
        switch key {
        case "clientId":
            return "Client ID".localized
        default:
            return ""
        }
    }

    override func serialize() -> String {
        var dict = Dictionary<String, Any>()
        dict["clientId"] = self.clientId

        return JSON(dict).rawString()!
    }

    static func deserialize(str: String?) -> ImgurHostConfig? {
        let config = ImgurHostConfig()
        guard let str = str else {
            return config
        }
        let data = str.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)
        config.clientId = json["clientId"].stringValue
        return config
    }
}
