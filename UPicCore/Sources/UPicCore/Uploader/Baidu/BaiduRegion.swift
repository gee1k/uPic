//
//  BaiduRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class BaiduRegion {
    /// https://cloud.baidu.com/doc/BOS/s/Ck1rk80hn#%E8%8E%B7%E5%8F%96%E8%AE%BF%E9%97%AE%E5%9F%9F%E5%90%8D
    public static let allRegions: [String] = [
        "bj",
        "bd",
        "su",
        "gz",
        "cd",
        "hkg",
        "fwh",
        "fsh"
    ].sorted()

    public static func endPoint(_ key: String) -> String {
        if key.isEmpty {
            return ""
        }
        return "\(key).bcebos.com"
    }
}
