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
    public static let allRegion: [String] = [
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
    ]
    
    public static func endPoint(_ key: String) -> String {
        if key.isEmpty {
            return ""
        }
        return "\(key).aliyuncs.com"
    }
}
