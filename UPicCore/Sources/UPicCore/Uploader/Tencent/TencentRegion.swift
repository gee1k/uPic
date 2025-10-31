//
//  TencentRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class TencentRegion {
    /// https://cloud.tencent.com/document/product/436/6224
    public static let allRegions: [String] = [
        "ap-beijing-1",
        "ap-beijing",
        "ap-nanjing",
        "ap-shanghai",
        "ap-guangzhou",
        "ap-chengdu",
        "ap-chongqing",
        "ap-shenzhen-fsi",
        "ap-shanghai-fsi",
        "ap-beijing-fsi",
        "ap-hongkong",
        "ap-singapore",
        "ap-jakarta",
        "ap-seoul",
        "ap-bangkok",
        "ap-tokyo",
        "na-siliconvalley",
        "na-ashburn",
        "sa-saopaulo",
        "eu-frankfurt"
    ].sorted()

    public static func displayName(for region: String) -> String {
        switch region {
        case "ap-beijing-1": return String(localized: "Beijing First District", bundle: .module)
        case "ap-beijing": return String(localized: "Beijing", bundle: .module)
        case "ap-nanjing": return String(localized: "Nanjing", bundle: .module)
        case "ap-shanghai": return String(localized: "Shanghai (East China)", bundle: .module)
        case "ap-guangzhou": return String(localized: "Guangzhou (South China)", bundle: .module)
        case "ap-chengdu": return String(localized: "Chengdu (Southwest)", bundle: .module)
        case "ap-chongqing": return String(localized: "Chongqing", bundle: .module)
        case "ap-shenzhen-fsi": return String(localized: "Shenzhen Finance", bundle: .module)
        case "ap-shanghai-fsi": return String(localized: "Shanghai Finance", bundle: .module)
        case "ap-beijing-fsi": return String(localized: "Beijing Finance", bundle: .module)
        case "ap-hongkong": return String(localized: "Hong Kong, China", bundle: .module)
        case "ap-singapore": return String(localized: "Singapore", bundle: .module)
        case "ap-jakarta": return String(localized: "Jakarta", bundle: .module)
        case "ap-seoul": return String(localized: "Seoul", bundle: .module)
        case "ap-bangkok": return String(localized: "Bangkok", bundle: .module)
        case "ap-tokyo": return String(localized: "Tokyo", bundle: .module)
        case "na-siliconvalley": return String(localized: "Silicon Valley", bundle: .module)
        case "na-ashburn": return String(localized: "Virginia", bundle: .module)
        case "sa-saopaulo": return String(localized: "Sao Paulo", bundle: .module)
        case "eu-frankfurt": return String(localized: "Frankfurt", bundle: .module)
        default: return region
        }
    }

    public static func endPoint(_ key: String) -> String {
        if key.isEmpty {
            return ""
        }
        return "cos.\(key).myqcloud.com"
    }
}
