//
//  AliyunUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

public class AliyunUtil {
    private static let expiration = 1800
    private static let schema = "https://"
    
    static func getPolicy(policyDict: Dictionary<String, Any>) -> String {
        // MARK: 将 policy 字典转成 JSON 然后转成 Data 再转 Base64
        
        var policyDict = policyDict
        
        if policyDict["expiration"] == nil {
            policyDict["expiration"] = Date(timeIntervalSince1970: TimeInterval(Date().timeStamp + expiration)).toISOString()
        }
        
        let policyJSON = JSON(policyDict)
        let policyData = try! policyJSON.rawData()
        return policyData.toBase64()
    }
    
    
    static func computeSignature(accessKeySecret: String, encodePolicy: String) -> String {
        return encodePolicy.calculateHMACByKey(key: accessKeySecret).toBase64() ?? ""
    }
    
    static func computeUrl(bucket: String, region: String) -> String {
        
        let endPoint = AliyunRegion.endPoint(region)
        
        if endPoint.isEmpty {
            return ""
        }
        
        return "\(schema)\(bucket).\(endPoint)"
    }
}
