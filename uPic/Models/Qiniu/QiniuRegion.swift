//
//  QiniuRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

class QiniuRegion {
    /// https://developer.qiniu.com/kodo/manual/1671/region-endpoint
    
    static let allRegion = [
        "z0": ["name": "华东-浙江"],
        "cn-east-2": ["name": "华东-浙江2"],
        "z1": ["name": "华北-河北"],
        "z2": ["name": "华南-广东"],
        "cn-northwest-1": ["name": "西北-陕西1"],
        "na0": ["name": "北美-洛杉矶"],
        "as0": ["name": "亚太-新加坡"],
        "ap-southeast-2": ["name": "亚太-河内"],
        "ap-southeast-3": ["name": "亚太-胡志明"]
    ]
    
    public static func name(_ key: String) -> String {
        guard let regionDict = allRegion[key] else {
            return key
        }
        return regionDict["name"] ?? key
    }
    
    public static func endPoint(_ key: String) -> String? {
        if key.isEmpty {
            return ""
        }
        return "https://up-\(key).qiniup.com"
    }
    
    public static func formatRegion(_ region: String?) -> String {
        if let region = region, !region.isEmpty {
            return region
        }
        return QiniuRegion.allRegion.keys.first!
    }
}
