//
//  BaiduRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/11/19.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class BaiduRegion {
    public static let allRegion = [
        "bj": ["name": "华北-北京"],
        "bd": ["name": "华北-保定"],
        "su": ["name": "华东-苏州"],
        "gz": ["name": "华南-广州"],
        "hkg": ["name": "中国香港"],
        "sin": ["name": "新加坡"],
        "fwh": ["name": "金融华东-武汉"],
        "fsh": ["name": "金融华东-上海"]
    ]
    
    public static func name(_ key: String) -> String {
        guard let regionDict = allRegion[key] else {
            return key
        }
        return regionDict["name"] ?? key
    }
    
    public static func endPoint(_ key: String) -> String {
        if key.isEmpty {
            return ""
        }
        return "\(key).bcebos.com"
    }
    
    public static func formatRegion(_ region: String?) -> String {
        if let region = region, !region.isEmpty {
            return region
        }
        return BaiduRegion.allRegion.keys.first!
    }
}
