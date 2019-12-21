//
//  TencentRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

class TencentRegion {
    
    /// https://cloud.tencent.com/document/product/436/6224
    public static let allRegion = [
        "ap-beijing-1": ["cname": "北京一区"],
        "ap-beijing": ["cname": "北京"],
        "ap-nanjing": ["cname": "南京"],
        "ap-shanghai": ["cname": "上海（华东）"],
        "ap-guangzhou": ["cname": "广州（华南）"],
        "ap-chengdu": ["cname": "成都（西南）"],
        "ap-chongqing": ["cname": "重庆"],
        "ap-shenzhen-fsi": ["cname": "深圳金融"],
        "ap-shanghai-fsi": ["cname": "上海金融"],
        "ap-beijing-fsi": ["cname": "北京金融"],
        "ap-hongkong": ["cname": "香港"],
        "ap-singapore": ["cname": "新加坡"],
        "ap-mumbai": ["cname": "孟买"],
        "ap-seoul": ["cname": "首尔"],
        "ap-bangkok": ["cname": "曼谷"],
        "ap-tokyo": ["cname": "东京"],
        "na-siliconvalley": ["cname": "硅谷"],
        "na-ashburn": ["cname": "弗吉尼亚"],
        "na-toronto": ["cname": "多伦多"],
        "eu-frankfurt": ["cname": "法兰克福"],
        "eu-moscow": ["cname": "莫斯科"]
    ]
    
    public static func name(_ key: String) -> String {
        guard let regionDict = allRegion[key] else {
            return key
        }
        return regionDict["cname"] ?? key
    }
    
    public static func endPoint(_ key: String) -> String {
        if key.isEmpty {
            return ""
        }
        return "cos.\(key).myqcloud.com"
    }
    
    public static func formatRegion(_ region: String?) -> String {
        if let region = region, !region.isEmpty {
            return region
        }
        return AliyunRegion.allRegion.keys.first!
    }
    
    /// FIXME： 将旧版区域转为新版格式，几个版本的迭代后需删除
    public static func upgradeFromOld(_ oldRegion: String) -> String {
        if oldRegion.isEmpty {
            return ""
        }
        return oldRegion.replacingOccurrences(of: "_", with: "-")
       
    }
}
