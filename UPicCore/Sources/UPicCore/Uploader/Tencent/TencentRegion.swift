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
    
    public static func endPoint(_ key: String) -> String {
        if key.isEmpty {
            return ""
        }
        return "cos.\(key).myqcloud.com"
    }
}

