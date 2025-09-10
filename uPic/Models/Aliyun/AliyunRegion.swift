//
//  AliyunRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

class AliyunRegion {
    
    /// https://help.aliyun.com/document_detail/31837.html?spm=a2c4g.11186623.3.3.61247c57V4n0QD
    public static let allRegion = [
        "oss-cn-hangzhou": ["cname": "华东 1（杭州）"],
        "oss-cn-shanghai": ["cname": "华东 2（上海）"],
        "oss-cn-nanjing": ["cname": "华东5（南京-本地地域）"],
        "oss-cn-fuzhou": ["cname": "华东6（福州-本地地域）"],
        "oss-cn-wuhan": ["cname": "华中1（武汉-本地地域）"],
        "oss-cn-qingdao": ["cname": "华北 1（青岛）"],
        "oss-cn-beijing": ["cname": "华北 2（北京）"],
        "oss-cn-zhangjiakou": ["cname": "华北 3（张家口）"],
        "oss-cn-huhehaote": ["cname": "华北 5（呼和浩特）"],
        "oss-cn-wulanchabu": ["cname": "华北 6（乌兰察布）"],
        "oss-cn-shenzhen": ["cname": "华南 1（深圳）"],
        "oss-cn-heyuan": ["cname": "华南 2（河源）"],
        "oss-cn-guangzhou": ["cname": "华南 3（广州）"],
        "oss-cn-chengdu": ["cname": "西南 1（成都）"],
        "oss-cn-hongkong": ["cname": "中国（香港）"],
        "oss-ap-northeast-1": ["cname": "日本（东京）"],
        "oss-ap-northeast-2": ["cname": "韩国（首尔）"],
        "oss-ap-southeast-1": ["cname": "新加坡"],
        "oss-ap-southeast-3": ["cname": "马来西亚（吉隆坡）"],
        "oss-ap-southeast-5": ["cname": "印度尼西亚（雅加达）"],
        "oss-ap-southeast-6": ["cname": "菲律宾（马尼拉）"],
        "oss-ap-southeast-7": ["cname": "泰国（曼谷）"],
        "oss-eu-central-1": ["cname": "德国（法兰克福）"],
        "oss-eu-west-1": ["cname": "英国（伦敦）"],
        "oss-us-west-1": ["cname": "美国（硅谷）"],
        "oss-us-east-1": ["cname": "美国（弗吉尼亚）"],
        "oss-na-south-1": ["cname": "墨西哥"],
        "oss-me-east-1": ["cname": "阿联酋（迪拜）"]
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
        return "\(key).aliyuncs.com"
    }
    
    public static func formatRegion(_ region: String?) -> String {
        if let region = region, !region.isEmpty {
            return region
        }
        return AliyunRegion.allRegion.keys.first!
    }
}
