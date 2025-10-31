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
    public dynamic var customize: Bool = false
    public dynamic var region: String?
    public dynamic var endpoint: String?
    public dynamic var bucket: String?
    public dynamic var acl: String?
    public dynamic var accessKey: String?
    public dynamic var secretKey: String?
    public dynamic var domain: String = ""
    public dynamic var saveKeyPath: String?
    public dynamic var suffix: String = ""

    override public func isValid() -> Bool {
        guard let bucket = self.bucket, !bucket.isEmpty,
              let accessKey = self.accessKey, !accessKey.isEmpty,
              let secretKey = self.secretKey, !secretKey.isEmpty
        else {
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
