//
//  GithubHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class GithubHostConfig: HostConfig {
    public dynamic var owner: String?
    public dynamic var repo: String?
    public dynamic var branch: String = "master"
    public dynamic var token: String?
    public dynamic var domain: String = ""
    public dynamic var saveKeyPath: String?
    public dynamic var useCdn: Bool = false

    override public func isValid() -> Bool {
        guard let repo = repo, !repo.isEmpty,
              let owner = owner, !owner.isEmpty,
              let token = token, !token.isEmpty
        else {
            return false
        }
        return true
    }
}
