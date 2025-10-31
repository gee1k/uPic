//
//  AliyunRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class AliyunRegion {
    /// https://help.aliyun.com/document_detail/31837.html?spm=a2c4g.11186623.3.3.61247c57V4n0QD
    public static let allRegions: [String] = [
        "oss-cn-hangzhou",
        "oss-cn-shanghai",
        "oss-cn-nanjing",
        "oss-cn-fuzhou",
        "oss-cn-wuhan-lr",
        "oss-cn-qingdao",
        "oss-cn-beijing",
        "oss-cn-zhangjiakou",
        "oss-cn-huhehaote",
        "oss-cn-wulanchabu",
        "oss-cn-shenzhen",
        "oss-cn-heyuan",
        "oss-cn-guangzhou",
        "oss-cn-chengdu",
        "oss-cn-hongkong",
        "oss-ap-northeast-1",
        "oss-ap-northeast-2",
        "oss-ap-southeast-1",
        "oss-ap-southeast-3",
        "oss-ap-southeast-5",
        "oss-ap-southeast-6",
        "oss-ap-southeast-7",
        "oss-eu-central-1",
        "oss-eu-west-1",
        "oss-us-west-1",
        "oss-us-east-1",
        "oss-na-south-1",
        "oss-me-east-1",
        "oss-rg-china-mainland"
    ].sorted()

    public static func displayName(for region: String) -> String {
        switch region {
        case "oss-cn-hangzhou": return String(localized: "East China 1 (Hangzhou)", bundle: .module)
        case "oss-cn-shanghai": return String(localized: "East China 2 (Shanghai)", bundle: .module)
        case "oss-cn-nanjing": return String(localized: "East China 5 (Nanjing)", bundle: .module)
        case "oss-cn-fuzhou": return String(localized: "East China 6 (Fuzhou)", bundle: .module)
        case "oss-cn-wuhan-lr": return String(localized: "Central China 1 (Wuhan)", bundle: .module)
        case "oss-cn-qingdao": return String(localized: "North China 1 (Qingdao)", bundle: .module)
        case "oss-cn-beijing": return String(localized: "North China 2 (Beijing)", bundle: .module)
        case "oss-cn-zhangjiakou": return String(localized: "North China 3 (Zhangjiakou)", bundle: .module)
        case "oss-cn-huhehaote": return String(localized: "North China 5 (Hohhot)", bundle: .module)
        case "oss-cn-wulanchabu": return String(localized: "North China 6 (Wulancha)", bundle: .module)
        case "oss-cn-shenzhen": return String(localized: "South China 1 (Shenzhen)", bundle: .module)
        case "oss-cn-heyuan": return String(localized: "South China 2 (Heyuan)", bundle: .module)
        case "oss-cn-guangzhou": return String(localized: "South China 3 (Guangzhou)", bundle: .module)
        case "oss-cn-chengdu": return String(localized: "Southwest 1 (Chengdu)", bundle: .module)
        case "oss-cn-hongkong": return String(localized: "China (Hong Kong)", bundle: .module)
        case "oss-ap-northeast-1": return String(localized: "Japan (Tokyo)", bundle: .module)
        case "oss-ap-northeast-2": return String(localized: "Korea (Seoul)", bundle: .module)
        case "oss-ap-southeast-1": return String(localized: "Singapore", bundle: .module)
        case "oss-ap-southeast-3": return String(localized: "Malaysia (Kuala Lumpur)", bundle: .module)
        case "oss-ap-southeast-5": return String(localized: "Indonesia (Jakarta)", bundle: .module)
        case "oss-ap-southeast-6": return String(localized: "Philippines (Manila)", bundle: .module)
        case "oss-ap-southeast-7": return String(localized: "Thailand (Bangkok)", bundle: .module)
        case "oss-eu-central-1": return String(localized: "Germany (Frankfurt)", bundle: .module)
        case "oss-eu-west-1": return String(localized: "London, (England)", bundle: .module)
        case "oss-us-west-1": return String(localized: "USA (Silicon Valley)", bundle: .module)
        case "oss-us-east-1": return String(localized: "USA (Virginia)", bundle: .module)
        case "oss-na-south-1": return String(localized: "Mexico", bundle: .module)
        case "oss-me-east-1": return String(localized: "United Arab Emirates (Dubai)", bundle: .module)
        case "oss-rg-china-mainland": return String(localized: "No geographical attributes (Mainland China)", bundle: .module)
        default: return region
        }
    }

    public static func endPoint(_ key: String) -> String {
        if key.isEmpty {
            return ""
        }
        return "\(key).aliyuncs.com"
    }
}
