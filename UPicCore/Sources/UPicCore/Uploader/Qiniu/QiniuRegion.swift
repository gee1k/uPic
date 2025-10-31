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

    public static let allRegions: [String] = [
        "z0",
        "cn-east-2",
        "z1",
        "z2",
        "cn-northwest-1",
        "na0",
        "as0",
        "ap-southeast-2",
        "ap-southeast-3"
    ].sorted()

    public static func displayName(for region: String) -> String {
        switch region {
        case "z0": return String(localized: "East China", bundle: .module)
        case "cn-east-2": return String(localized: "East China - Zhejiang 2", bundle: .module)
        case "z1": return String(localized: "North China", bundle: .module)
        case "z2": return String(localized: "South China", bundle: .module)
        case "cn-northwest-1": return String(localized: "Northwest China - Shaanxi 1", bundle: .module)
        case "na0": return String(localized: "North America", bundle: .module)
        case "as0": return String(localized: "Asia Pacific - Singapore", bundle: .module)
        case "ap-southeast-2": return String(localized: "Asia Pacific - Hanoi", bundle: .module)
        case "ap-southeast-3": return String(localized: "Asia Pacific - Ho Chi Minh", bundle: .module)
        default: return region
        }
    }

    public static func endPoint(_ key: String) -> String? {
        if key.isEmpty {
            return ""
        }
        return "https://up-\(key).qiniup.com"
    }
}
