//
//  SmmsHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class SmmsHostConfig: HostConfig {
    dynamic public var token: String?
    
    public override func isValid() -> Bool {
        guard let token = self.token, !token.isEmpty else {
            return false
        }
        return true
    }
}
