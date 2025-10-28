//
//  UpyunHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class UpyunHostConfig: HostConfig {
    dynamic public var bucket: String?
    dynamic public var operatorName: String?
    dynamic public var password: String?
    dynamic public var domain: String = ""
    dynamic public var saveKeyPath: String?
    dynamic public var suffix: String = ""
    
    public override func isValid() -> Bool {
        guard let operatorName = self.operatorName, !operatorName.isEmpty,
            let bucket = self.bucket, !bucket.isEmpty,
            let password = self.password, !password.isEmpty else {
            return false
        }
        return true
    }
}
