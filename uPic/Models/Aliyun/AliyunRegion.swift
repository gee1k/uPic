//
//  AliyunRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

class AliyunRegionDict {
    static let allRegion = [
        "cn_hangzhou": ["name": "华东 1", "endPoint": "oss-cn-hangzhou"],
        "cn_shanghai": ["name": "华东 2", "endPoint": "oss-cn-shanghai"],
        "cn_qingdao": ["name": "华北 1", "endPoint": "oss-cn-qingdao"],
        "cn_beijing": ["name": "华北 2", "endPoint": "oss-cn-beijing"],
        "cn_zhangjiakou": ["name": "华北 3", "endPoint": "oss-cn-zhangjiakou"],
        "cn_huhehaote": ["name": "华北 5", "endPoint": "oss-cn-huhehaote"],
        "cn_shenzhen": ["name": "华南 1", "endPoint": "oss-cn-shenzhen"],
        "cn_hongkong": ["name": "香港", "endPoint": "oss-cn-hongkong"],
        "us_west_1": ["name": "美国西部 1（硅谷）", "endPoint": "oss-us-west-1"],
        "us_east_1": ["name": "美国东部 1（弗吉尼亚）", "endPoint": "oss-us-east-1"],
        "ap_southeast_1": ["name": "亚太东南 1（新加坡）", "endPoint": "oss-ap-southeast-1"],
        "ap_southeast_2": ["name": "亚太东南 2（悉尼）", "endPoint": "oss-ap-southeast-2"],
        "ap_southeast_3": ["name": "亚太东南 3（吉隆坡）", "endPoint": "oss-ap-southeast-3"],
        "ap_southeast_5": ["name": "亚太东南 5 （雅加达）", "endPoint": "oss-ap-southeast-5"],
        "ap_northeast_1": ["name": "亚太东北 1 （日本）", "endPoint": "oss-ap-northeast-1"],
        "ap_south_1": ["name": "亚太南部 1 （孟买）", "endPoint": "oss-ap-south-1"],
        "eu_central_1": ["name": "欧洲中部 1 （法兰克福）", "endPoint": "oss-eu-central-1"],
        "eu_west_1": ["name": "英国（伦敦）", "endPoint": "oss-eu-west-1"],
        "me_east_1": ["name": "中东东部 1 （迪拜）", "endPoint": "oss-me-east-1"]
    ]
}

public enum AliyunRegion: String, CaseIterable {
    case cn_hangzhou
    case cn_shanghai
    case cn_qingdao
    case cn_beijing
    case cn_zhangjiakou
    case cn_huhehaote
    case cn_shenzhen
    case cn_hongkong
    case us_west_1
    case us_east_1
    case ap_southeast_1
    case ap_southeast_2
    case ap_southeast_3
    case ap_southeast_5
    case ap_northeast_1
    case ap_south_1
    case eu_central_1
    case eu_west_1
    case me_east_1
    
    public var name: String {
        get {
            guard let regionDict = AliyunRegionDict.allRegion[self.rawValue], let cname = regionDict["name"] else {
                return self.rawValue
            }
            
            return "【\(cname)】\(self.rawValue)"
        }
    }
    
    public var endPoint: String {
        get {
            guard let regionDict = AliyunRegionDict.allRegion[self.rawValue], let endPoint = regionDict["endPoint"] else {
                return ""
            }
            return "\(endPoint).aliyuncs.com"
        }
    }
    
    public static func formatRegion(_ region: String?) -> AliyunRegion {
        if let region = region, !region.isEmpty {
            return AliyunRegion(rawValue: region)!
        }
        return AliyunRegion.cn_hangzhou
    }
}
