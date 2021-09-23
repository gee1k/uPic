//
//  S3Region.swift
//  uPic
//
//  Created by Svend Jin on 2020/8/13.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation
import SotoS3

public class S3Region {
    /// https://docs.aws.amazon.com/general/latest/gr/rande.html
    
    /// 与 AWS SDK 中 region 对应
    
    public static let allRegion = [
        "us-east-1": ["cname": "美国东部（弗吉尼亚北部）", "name": "US East (N. Virginia)"],
        "us-east-2": ["cname": "美国东部（俄亥俄州）", "name": "US East (Ohio)"],
        "us-west-1": ["cname": "美国西部（加利福尼亚北部）", "name": "US West (N. California)"],
        "us-west-2": ["cname": "美国西部（俄勒冈）", "name": "US West (Oregon)"],
        "af-south-1": ["cname": "非洲（开普敦）", "name": "Africa (Cape Town)"],
        "ap-east-1": ["cname": "亚太地区（香港）", "name": "Asia Pacific (Hong Kong)"],
        "ap-south-1": ["cname": "亚太地区（孟买）", "name": "Asia Pacific (Mumbai)"],
        "ap-northeast-3": ["cname": "亚太区域 (大阪当地)", "name": "Asia Pacific (Osaka-Local)"],
        "ap-northeast-2": ["cname": "亚太区域（首尔）", "name": "Asia Pacific (Seoul)"],
        "ap-southeast-1": ["cname": "亚太区域（新加坡）", "name": "Asia Pacific (Singapore)"],
        "ap-southeast-2": ["cname": "亚太区域（悉尼）", "name": "Asia Pacific (Sydney)"],
        "ap-northeast-1": ["cname": "亚太区域（东京）", "name": "Asia Pacific (Tokyo)"],
        "ca-central-1": ["cname": "加拿大 (中部)", "name": "Canada (Central)"],
        //
        "eu-central-1": ["cname": "欧洲（法兰克福）", "name": "Europe (Frankfurt)"],
        "eu-west-1": ["cname": "欧洲（爱尔兰）", "name": "Europe (Ireland)"],
        "eu-west-2": ["cname": "欧洲（伦敦）", "name": "Europe (London)"],
        "eu-south-1": ["cname": "欧洲（米兰）", "name": "Europe (Milan)"],
        "eu-west-3": ["cname": "欧洲 (巴黎)", "name": "Europe (Paris)"],
        "eu-north-1": ["cname": "欧洲（斯德哥尔摩）", "name": "Europe (Stockholm)"],
        "me-south-1": ["cname": "中东（巴林）", "name": "Middle East (Bahrain)"],
        "sa-east-1": ["cname": "南美洲（圣保罗）", "name": "South America (São Paulo)"],
        // 中国
        "cn-north-1": ["cname": "中国（北京）", "name": "China (Beijing)"],
        "cn-northwest-1": ["cname": "中国 (宁夏)", "name": "China (Ningxia)"]
    ]
    
    public static func name(_ key: String) -> String {
        guard let regionDict = allRegion[key] else {
            return key
        }
        
        let language = Util.getCurrentLanguage()
        if language == "cn" {
            return regionDict["cname"] ?? key
        }
        
        return regionDict["name"] ?? key
    }
    
    public static func endPoint(_ key: String?) -> String {
        guard let key = key, !key.isEmpty else {
            return ""
        }
        if key == "cn-north-1" || key == "cn-northwest-1" {
            return "s3.\(key).amazonaws.com.cn"
        }
        return "s3.\(key).amazonaws.com"
    }
    
    public static func formatRegion(_ region: String?) -> String {
        if let region = region, !region.isEmpty {
            return region
        }
        return S3Region.allRegion.keys.first!
    }
    
    public static func toS3Region(_ key: String) -> SotoS3.Region? {
            return SotoS3.Region(rawValue: key)
    }
}
