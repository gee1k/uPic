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
    
    static func computeUrl(bucket: String, region: String) -> String {
        
        let endPoint = TencentRegion.endPoint(region)
        
        if endPoint.isEmpty {
            return ""
        }
        
        return "\(schema)\(bucket).\(endPoint)"
    }
    
    static func computeHost(bucket: String, region: String) -> String {
        let endPoint = TencentRegion.endPoint(region)
        
        if endPoint.isEmpty {
            return ""
        }
        
        return "\(bucket).\(endPoint)"
    }
    
    static func getKeyTime() -> String {
        return "\(Date().timeStamp);\(Date().timeStamp + expiration)"
    }
}
