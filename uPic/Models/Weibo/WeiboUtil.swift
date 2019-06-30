//
//  WeiboUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

class WeiboUtil {
    static func parsePicPid(reponseString: String) -> String? {
        var regex = try! Regex("<.*?/>")
        var result = regex.replacingMatches(in: reponseString, with: "")
        regex = try! Regex("<(\\w+).*?>.*?</\\1>")
        result = regex.replacingMatches(in: result, with: "").trim()
        let json = JSON(parseJSON: result)
        return json["data"]["pics"]["pic_1"]["pid"].string
    }
}
