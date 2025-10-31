//
//  WeiboHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class WeiboHostConfig: HostConfig {
    public dynamic var username: String?
    public dynamic var password: String?
    public dynamic var cookieMode: Bool = false
    public dynamic var cookie: String?
    public dynamic var quality: WeiboqQuality = .large

    // 微博图片访问域名，有少数域名还没有防盗连
    // ws1.sinaimg.cn
    public var domain: String = "https://tva1.sinaimg.cn"

    override public func isValid() -> Bool {
        if self.cookieMode {
            guard let cookie = cookie, !cookie.isEmpty else {
                return false
            }
        } else {
            guard let username = self.username, !username.isEmpty,
                  let password = self.password, !password.isEmpty
            else {
                return false
            }
        }
        return true
    }
}
