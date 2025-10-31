//
//  S3Region.swift
//  Alamofire
//
//  Created by Svend Jin on 2020/8/16.
//

import Foundation

public class S3Region {
    /// https://docs.aws.amazon.com/general/latest/gr/rande.html

    public static let allRegions: [String] = [
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
    ].sorted()

    public static func displayName(for region: String) -> String {
        switch region {
        case "us-east-2": return String(localized: "US East (Ohio)", bundle: .module)
        case "us-east-1": return String(localized: "US East (N. Virginia)", bundle: .module)
        case "us-west-1": return String(localized: "US West (N. California)", bundle: .module)
        case "us-west-2": return String(localized: "US West (Oregon)", bundle: .module)
        case "af-south-1": return String(localized: "Africa (Cape Town)", bundle: .module)
        case "ap-east-1": return String(localized: "Asia Pacific (Hong Kong)", bundle: .module)
        case "ap-south-2": return String(localized: "Asia Pacific (Hyderabad)", bundle: .module)
        case "ap-southeast-3": return String(localized: "Asia Pacific (Jakarta)", bundle: .module)
        case "ap-southeast-5": return String(localized: "Asia Pacific (Malaysia)", bundle: .module)
        case "ap-southeast-4": return String(localized: "Asia Pacific (Melbourne)", bundle: .module)
        case "ap-south-1": return String(localized: "Asia Pacific (Mumbai)", bundle: .module)
        case "ap-northeast-3": return String(localized: "Asia Pacific (Osaka)", bundle: .module)
        case "ap-northeast-2": return String(localized: "Asia Pacific (Seoul)", bundle: .module)
        case "ap-southeast-1": return String(localized: "Asia Pacific (Singapore)", bundle: .module)
        case "ap-southeast-2": return String(localized: "Asia Pacific (Sydney)", bundle: .module)
        case "ap-southeast-7": return String(localized: "Asia Pacific (Thailand)", bundle: .module)
        case "ap-northeast-1": return String(localized: "Asia Pacific (Tokyo)", bundle: .module)
        case "ca-central-1": return String(localized: "Canada (Central)", bundle: .module)
        case "ca-west-1": return String(localized: "Canada West (Calgary)", bundle: .module)
        case "eu-central-1": return String(localized: "Europe (Frankfurt)", bundle: .module)
        case "eu-west-1": return String(localized: "Europe (Ireland)", bundle: .module)
        case "eu-west-2": return String(localized: "Europe (London)", bundle: .module)
        case "eu-south-1": return String(localized: "Europe (Milan)", bundle: .module)
        case "eu-west-3": return String(localized: "Europe (Paris)", bundle: .module)
        case "eu-south-2": return String(localized: "Europe (Spain)", bundle: .module)
        case "eu-north-1": return String(localized: "Europe (Stockholm)", bundle: .module)
        case "eu-central-2": return String(localized: "Europe (Zurich)", bundle: .module)
        case "il-central-1": return String(localized: "Israel (Tel Aviv)", bundle: .module)
        case "mx-central-1": return String(localized: "Mexico (Central)", bundle: .module)
        case "me-south-1": return String(localized: "Middle East (Bahrain)", bundle: .module)
        case "me-central-1": return String(localized: "Middle East (UAE)", bundle: .module)
        case "sa-east-1": return String(localized: "South America (São Paulo)", bundle: .module)
        case "us-gov-east-1": return String(localized: "AWS GovCloud (US-East)", bundle: .module)
        case "us-gov-west-1": return String(localized: "AWS GovCloud (US-West)", bundle: .module)
        default: return region
        }
    }

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
