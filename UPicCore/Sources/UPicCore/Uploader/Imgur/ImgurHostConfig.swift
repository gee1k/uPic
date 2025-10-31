//
//  ImgurHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class ImgurHostConfig: HostConfig {
    public dynamic var clientId: String?

    override public func isValid() -> Bool {
        guard let clientId = clientId, !clientId.isEmpty else {
            return false
        }
        return true
    }
}
