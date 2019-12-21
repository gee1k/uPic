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
        "oss-cn-qingdao": ["cname": "华北 1（青岛）"],
        "oss-cn-beijing": ["cname": "华北 2（北京）"],
        "oss-cn-zhangjiakou": ["cname": "华北 3（张家口）"],
        "oss-cn-huhehaote": ["cname": "华北 5（呼和浩特）"],
        "oss-cn-shenzhen": ["cname": "华南 1（深圳）"],
        "oss-cn-chengdu": ["cname": "西南 1（成都）"],
        "oss-cn-hongkong": ["cname": "香港"],
        "oss-us-west-1": ["cname": "美国西部 1（硅谷）"],
        "oss-us-east-1": ["cname": "美国东部 1（弗吉尼亚）"],
        "oss-ap-southeast-1": ["cname": "亚太东南 1（新加坡）"],
        "oss-ap-southeast-2": ["cname": "亚太东南 2（悉尼）"],
        "oss-ap-southeast-3": ["cname": "亚太东南 3（吉隆坡）"],
        "oss-ap-southeast-5": ["cname": "亚太东南 5（雅加达）"],
        "oss-ap-northeast-1": ["cname": "亚太东北 1（日本）"],
        "oss-ap-south-1": ["cname": "亚太南部 1（孟买）"],
        "oss-eu-central-1": ["cname": "欧洲中部 1（法兰克福）"],
        "oss-eu-west-1": ["cname": "英国（伦敦）"],
        "oss-me-east-1": ["cname": "中东东部 1（迪拜）"]
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
    
    /// FIXME： 将旧版区域转为新版格式，几个版本的迭代后需删除
    public static func upgradeFromOld(_ oldRegion: String) -> String {
        if (oldRegion.starts(with: "oss-")) {
            return oldRegion
        }
        
        if oldRegion.isEmpty {
            return ""
        }
        return "oss-\(oldRegion.replacingOccurrences(of: "_", with: "-"))"
       
    }
}
