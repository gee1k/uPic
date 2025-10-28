//
//  WeiboHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class WeiboHostConfig: HostConfig {
    dynamic public var username: String?
    dynamic public var password: String?
    dynamic public var cookieMode: Bool = false
    dynamic public var cookie: String?
    dynamic public var quality: WeiboqQuality = WeiboqQuality.large
    
    // 微博图片访问域名，有少数域名还没有防盗连
    // ws1.sinaimg.cn
    public var domain: String = "https://tva1.sinaimg.cn"
    
    public override func isValid() -> Bool {
        if self.cookieMode {
            guard let cookie = cookie, !cookie.isEmpty else {
                return false
            }
        } else {
            guard let username = self.username, !username.isEmpty,
                let password = self.password, !password.isEmpty else {
                return false
            }
        }
        return true
    }
}
