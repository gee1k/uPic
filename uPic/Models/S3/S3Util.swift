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
    
    static func computeUrl(bucket: String, region: String, endpoint: String?) -> String {
        
        if let endpoint = endpoint {
            if (endpoint.last == "/") {
                return "\(endpoint)\(bucket)"
            }
            return "\(endpoint)/\(bucket)"
        } else {
            let cEndpoint = "s3.\(region).amazonaws.com"
            return "\(schema)\(bucket).\(cEndpoint)"
        }
    }
}
