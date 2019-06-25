//
//  TencentUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

public class TencentUtil {
    private static let expiration = 1800
    private static let schema = "https://"

    static func getPolicy(policyDict: Dictionary<String, Any>) -> String {
        var policyDict = policyDict

        if policyDict["expiration"] == nil {
            policyDict["expiration"] = Date(timeIntervalSince1970: TimeInterval(Date().timeStamp + expiration)).toISOString()
        }
        
        let policyJSON = JSON(policyDict)
        let policyData = try! policyJSON.rawData()
        return policyData.toBase64()
    }
    
    static func computeUrl(bucket: String, region: TencentRegion) -> String {
        if region.endPoint.isEmpty {
            return ""
        }
        
        return "\(schema)\(bucket).\(region.endPoint)"
    }
    
    static func computeHost(bucket: String, region: TencentRegion) -> String {
        if region.endPoint.isEmpty {
            return ""
        }
        
        return "\(bucket).\(region.endPoint)"
    }
    
    static func getKeyTime() -> String {
        return "\(Date().timeStamp);\(Date().timeStamp + expiration)"
    }
}
