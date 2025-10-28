//
//  BaiduHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class BaiduHostConfig: HostConfig {
    dynamic public var region: String?
    dynamic public var bucket: String?
    dynamic public var accessKey: String?
    dynamic public var secretKey: String?
    dynamic public var domain: String = ""
    dynamic public var saveKeyPath: String?
    dynamic public var suffix: String = ""
    
    public override func isValid() -> Bool {
        guard let region = self.region, !region.isEmpty,
            let bucket = self.bucket, !bucket.isEmpty,
            let accessKey = self.accessKey, !accessKey.isEmpty,
            let secretKey = self.secretKey, !secretKey.isEmpty else {
            return false
        }
        return true
    }
}
