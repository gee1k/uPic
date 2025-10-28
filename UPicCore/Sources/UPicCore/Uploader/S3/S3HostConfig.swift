//
//  S3HostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2020/08/16.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation
import SotoS3

extension S3.ObjectCannedACL: @retroactive CaseIterable {
    public static var allCases: [S3.ObjectCannedACL] {
        return [.publicRead, .publicReadWrite, .private, .authenticatedRead, .awsExecRead, .bucketOwnerFullControl, .bucketOwnerRead]
    }
}

public typealias S3ObjectCannedACL = S3.ObjectCannedACL

public class S3HostConfig: HostConfig {
    dynamic public var customize: Bool = false
    dynamic public var region: String?
    dynamic public var endpoint: String?
    dynamic public var bucket: String?
    dynamic public var acl: String?
    dynamic public var accessKey: String?
    dynamic public var secretKey: String?
    dynamic public var domain: String = ""
    dynamic public var saveKeyPath: String?
    dynamic public var suffix: String = ""
    
    public override func isValid() -> Bool {
        guard let bucket = self.bucket, !bucket.isEmpty,
            let accessKey = self.accessKey, !accessKey.isEmpty,
            let secretKey = self.secretKey, !secretKey.isEmpty else {
            return false
        }
        
        if self.customize {
            guard let endpoint = self.endpoint, !endpoint.isEmpty else {
                return false
            }
        } else {
            guard let region = self.region, !region.isEmpty else {
                return false
            }
        }
        return true
    }
}
