//
//  BaiduUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/11/19.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

public class BaiduUtil {
    private static let expiration = 1800
    private static let schema = "https://"
    
    static func getPolicy(policyDict: Dictionary<String, Any>) -> String {
        var policyDict = policyDict
        
        if policyDict["expiration"] == nil {
            let date = Date(timeIntervalSince1970: TimeInterval(Date().timeStamp + expiration)).toISOString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss'Z'")
            policyDict["expiration"] = date
        }
        
        let policyJSON = JSON(policyDict)
        
        let policy = try! policyJSON.rawData()
        return policy.toBase64()
    }
    
    
    static func computeSignature(accessKeySecret: String, encodePolicy: String) -> String {
        return encodePolicy.calculateHMAC256ByKey(key: accessKeySecret).toHexString()
    }
    
    static func computeUrl(bucket: String, region: String) -> String {
        let endPoint = BaiduRegion.endPoint(region)
        
        if endPoint.isEmpty {
            return ""
        }
        
        return "\(schema)\(bucket).\(endPoint)"
    }
}
