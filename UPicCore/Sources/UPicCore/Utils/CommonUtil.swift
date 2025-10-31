//
//  CommonUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

class CommonUtil {
    static func getCurrentLanguage() -> String {
        let preferredLang = Bundle.main.preferredLocalizations.first! as NSString

        switch String(describing: preferredLang) {
        case "en-US", "en-CN":
            return "en" // 英文
        case "zh-Hans-US", "zh-Hans-CN", "zh-Hant-CN", "zh-TW", "zh-HK", "zh-Hans":
            return "cn" // 中文
        default:
            return "en"
        }
    }
}
