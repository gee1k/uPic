//
//  GiteeHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class GiteeHostConfig: HostConfig {
    dynamic public var owner: String?
    dynamic public var repo: String?
    dynamic public var branch: String = "master"
    dynamic public var token: String?
    dynamic public var domain: String = ""
    dynamic public var saveKeyPath: String?
    
    public override func isValid() -> Bool {
        guard let repo = self.repo, !repo.isEmpty,
            let owner = self.owner, !owner.isEmpty,
            let token = self.token, !token.isEmpty else {
            return false
        }
        return true
    }
}
