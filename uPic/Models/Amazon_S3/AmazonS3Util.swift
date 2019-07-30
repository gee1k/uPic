//
//  AmazonS3Util.swift
//  uPic
//
//  Created by Svend Jin on 2019/7/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

public class AmazonS3Util {
    private static let expiration = 1800
    private static let schema = "https://"
    public static let SEVICE_NAME = "s3"
    public static let SCHEME = "AWS4";
    public static let ALGORITHM = "AWS4-HMAC-SHA256";
    public static let TERMINATOR = "aws4_request";
    
    static func getCredential(access_key: String, short_date: String, region: String) -> String {
        return "\(access_key)/\(short_date)/\(region)/\(SEVICE_NAME)/\(TERMINATOR)"
    }

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
    
    
    static func computeSignature(secret_key: String, policy: String, region: String, short_date: String) -> String {
        
        //Signature calculation (AWS Signature Version 4)
        //For more info http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html
        
        let kDate = short_date.calculateHMAC256ByKey(key: "\(SCHEME)\(secret_key)".bytes)
        let kRegion = region.calculateHMAC256ByKey(key: kDate)
        let kService = SEVICE_NAME.calculateHMAC256ByKey(key: kRegion)
        let kSigning = TERMINATOR.calculateHMAC256ByKey(key: kService)
        let signature = policy.calculateHMAC256ByKey(key: kSigning)
        
        return signature.toHexString()
    }
    
    static func computeUrl(bucket: String, region: String) -> String {
        let endPoint = AmazonS3Region.endPoint(region)
        
        if endPoint.isEmpty {
            return ""
        }
        
        return "\(schema)\(bucket).\(endPoint)"
    }
}
