//
//  QiniuRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

class QiniuRegionDict {
    /// https://developer.qiniu.com/kodo/manual/1671/region-endpoint
    static let allRegion = [
        "z0": ["name": "华东", "url": "https://upload.qiniup.com"],
        "z1": ["name": "华北", "url": "https://upload-z1.qiniup.com"],
        "z2": ["name": "华南", "url": "https://upload-z2.qiniup.com"],
        "na0": ["name": "北美", "url": "https://upload-na0.qiniup.com"],
        "as0": ["name": "东南亚", "url": "https://upload-as0.qiniup.com"]
    ]
}

public enum QiniuRegion: String, CaseIterable {
    case z0
    case z1
    case z2
    case na0
    case as0
    
    public var name: String {
        get {
            guard let regionDict = QiniuRegionDict.allRegion[self.rawValue], let cname = regionDict["name"] else {
                return self.rawValue
            }
            
            return "【\(cname)】\(self.rawValue)"
        }
    }
    
    public var url: String {
        get {
            guard let regionDict = QiniuRegionDict.allRegion[self.rawValue], let url = regionDict["url"] else {
                return ""
            }
            return url
        }
    }
    
    public static func formatRegion(_ region: String?) -> QiniuRegion {
        if let region = region, !region.isEmpty {
            return QiniuRegion(rawValue: region)!
        }
        return QiniuRegion.z0
    }
}
