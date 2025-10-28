//
//  QiniuRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class QiniuRegion {
    /// https://developer.qiniu.com/kodo/manual/1671/region-endpoint
    
    public static let allRegion: [String] = [
        "z0",
        "cn-east-2",
        "z1",
        "z2",
        "cn-northwest-1",
        "na0",
        "as0",
        "ap-southeast-2",
        "ap-southeast-3"
    ]
    
    public static func endPoint(_ key: String) -> String? {
        if key.isEmpty {
            return ""
        }
        return "https://up-\(key).qiniup.com"
    }
}
