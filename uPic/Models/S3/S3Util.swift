//
//  S3Util.swift
//  uPic
//
//  Created by Svend Jin on 2020/8/13.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

public class S3Util {
    private static let schema = "https://"
    
    static func computeUrl(bucket: String, region: String?, customize: Bool, endpoint: String?) -> String {
        
        if customize, let endpoint = endpoint {
            if (endpoint.last == "/") {
                return "\(endpoint)\(bucket)"
            }
            return "\(endpoint)/\(bucket)"
        } else {
            let cEndpoint = S3Region.endPoint(region)
            return "\(schema)\(bucket).\(cEndpoint)"
        }
    }
    
    static func computedS3Endpoint(_ endpoint: String?) -> String? {
        if var point = endpoint, URL(string: point)?.scheme == nil {
            point = schema + point
            return point
        }
        return endpoint
    }
}
