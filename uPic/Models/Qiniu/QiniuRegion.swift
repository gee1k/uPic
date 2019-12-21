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
        "z0": ["name": "华东", "url": "https://upload.qiniup.com"],
        "z1": ["name": "华北", "url": "https://upload-z1.qiniup.com"],
        "z2": ["name": "华南", "url": "https://upload-z2.qiniup.com"],
        "na0": ["name": "北美", "url": "https://upload-na0.qiniup.com"],
        "as0": ["name": "东南亚", "url": "https://upload-as0.qiniup.com"]
    ]
    
    public static func name(_ key: String) -> String {
        guard let regionDict = allRegion[key] else {
            return key
        }
        return regionDict["name"] ?? key
    }
    
    public static func endPoint(_ key: String) -> String? {
        guard let regionDict = allRegion[key] else {
            return nil
        }
        return regionDict["url"]
    }
    
    public static func formatRegion(_ region: String?) -> String {
        if let region = region, !region.isEmpty {
            return region
        }
        return QiniuRegion.allRegion.keys.first!
    }
}
