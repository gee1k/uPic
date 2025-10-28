//
//  S3Region.swift
//  Alamofire
//
//  Created by Svend Jin on 2020/8/16.
//

import Foundation

public class S3Region {
    /// https://docs.aws.amazon.com/general/latest/gr/rande.html
    
    public static let allRegion: [String] = [
        "us-east-2",
        "us-east-1",
        "us-west-1",
        "us-west-2",
        "af-south-1",
        "ap-east-1",
        "ap-south-2",
        "ap-southeast-3",
        "ap-southeast-5",
        "ap-southeast-4",
        "ap-south-1",
        "ap-northeast-3",
        "ap-northeast-2",
        "ap-southeast-1",
        "ap-southeast-2",
        "ap-southeast-7",
        "ap-northeast-1",
        "ca-central-1",
        "ca-west-1",
        "eu-central-1",
        "eu-west-1",
        "eu-west-2",
        "eu-south-1",
        "eu-west-3",
        "eu-south-2",
        "eu-north-1",
        "eu-central-2",
        "il-central-1",
        "mx-central-1",
        "me-south-1",
        "me-central-1",
        "sa-east-1",
        "us-gov-east-1",
        "us-gov-west-1"
    ]
    
    public static func endPoint(_ key: String) -> String {
        if key.isEmpty {
            return ""
        }
        if key == "cn-north-1" || key == "cn-northwest-1" {
            return "s3.\(key).amazonaws.com.cn"
        }
        return "s3.\(key).amazonaws.com"
    }
}
