//
//  UpyunHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class UpyunHostConfig: HostConfig {
    public dynamic var bucket: String?
    public dynamic var operatorName: String?
    public dynamic var password: String?
    public dynamic var domain: String = ""
    public dynamic var saveKeyPath: String?
    public dynamic var suffix: String = ""

    override public func isValid() -> Bool {
        guard let operatorName = operatorName, !operatorName.isEmpty,
              let bucket = bucket, !bucket.isEmpty,
              let password = password, !password.isEmpty
        else {
            return false
        }
        return true
    }
}
