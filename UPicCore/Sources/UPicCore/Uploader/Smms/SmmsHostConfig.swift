//
//  SmmsHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class SmmsHostConfig: HostConfig {
    public dynamic var token: String?

    override public func isValid() -> Bool {
        guard let token = token, !token.isEmpty else {
            return false
        }
        return true
    }
}
