//
//  AliyunHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class AliyunHostConfig: HostConfig {
    public dynamic var region: String?
    public dynamic var bucket: String?
    public dynamic var accessKey: String?
    public dynamic var secretKey: String?
    public dynamic var domain: String = ""
    public dynamic var saveKeyPath: String?
    public dynamic var suffix: String = ""

    override public func isValid() -> Bool {
        guard let region = region, !region.isEmpty,
              let bucket = bucket, !bucket.isEmpty,
              let accessKey = accessKey, !accessKey.isEmpty,
              let secretKey = secretKey, !secretKey.isEmpty
        else {
            return false
        }
        return true
    }
}
