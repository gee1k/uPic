//
//  TencentRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

class TencentRegionDict {
    static let allRegion = [
        // 内地
        "ap_beijing_1": ["name": "北京一区", "endPoint": "cos.ap-beijing-1.myqcloud.com"],
        "ap_beijing": ["name": "北京", "endPoint": "cos.ap-beijing.myqcloud.com"],
        "ap_shanghai": ["name": "上海（华东）", "endPoint": "cos.ap-shanghai.myqcloud.com"],
        "ap_guangzhou": ["name": "广州（华南）", "endPoint": "cos.ap-guangzhou.myqcloud.com"],
        "ap_chengdu": ["name": "成都（西南）", "endPoint": "cos.ap-chengdu.myqcloud.com"],
        "ap_chongqing": ["name": "重庆", "endPoint": "cos.ap-chongqing.myqcloud.com"],
        "ap_shenzhen_fsi": ["name": "深圳金融", "endPoint": "cos.ap-shenzhen-fsi.myqcloud.com"],
        "ap_shanghai_fsi": ["name": "上海金融", "endPoint": "cos.ap-shanghai-fsi.myqcloud.com"],
        // 中国香港及海外地域
        "ap_hongkong": ["name": "香港", "endPoint": "cos.ap-hongkong.myqcloud.com"],
        "ap_singapore": ["name": "新加坡", "endPoint": "cos.ap-singapore.myqcloud.com"],
        "ap_mumbai": ["name": "孟买", "endPoint": "cos.ap-mumbai.myqcloud.com"],
        "ap_seoul": ["name": "首尔", "endPoint": "cos.ap-seoul.myqcloud.com"],
        "ap_bangkok": ["name": "曼谷", "endPoint": "cos.ap-bangkok.myqcloud.com"],
        "ap_tokyo": ["name": "东京", "endPoint": "cos.ap-tokyo.myqcloud.com"],
        "na_siliconvalley": ["name": "硅谷", "endPoint": "cos.na-siliconvalley.myqcloud.com"],
        "na_ashburn": ["name": "弗吉尼亚", "endPoint": "cos.na-ashburn.myqcloud.com"],
        "na_toronto": ["name": "多伦多", "endPoint": "cos.na-toronto.myqcloud.com"],
        "eu_frankfurt": ["name": "法兰克福", "endPoint": "cos.eu-frankfurt.myqcloud.com"],
        "eu_moscow": ["name": "莫斯科", "endPoint": "cos.eu-moscow.myqcloud.com"]
    ]
}

public enum TencentRegion: String, CaseIterable {
    case ap_beijing_1
    case ap_beijing
    case ap_shanghai
    case ap_guangzhou
    case ap_chengdu
    case ap_chongqing
    case ap_shenzhen_fsi
    case ap_shanghai_fsi
    case ap_hongkong
    case ap_singapore
    case ap_mumbai
    case ap_seoul
    case ap_bangkok
    case ap_tokyo
    case na_siliconvalley
    case na_ashburn
    case na_toronto
    case eu_frankfurt
    case eu_moscow

    public var name: String {
        get {
            guard let regionDict = TencentRegionDict.allRegion[self.rawValue], let cname = regionDict["name"] else {
                return self.rawValue
            }
            
            return "【\(cname)】\(self.rawValue)"
        }
    }
    
    public var endPoint: String {
        get {
            guard let regionDict = TencentRegionDict.allRegion[self.rawValue], let endPoint = regionDict["endPoint"] else {
                return ""
            }
            return endPoint
        }
    }
}
