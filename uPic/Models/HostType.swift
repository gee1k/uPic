//
//  HostType.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/15.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public enum HostType: Int, CaseIterable, Codable {
    // MARK: 写了固定的数值原因是为了这里的顺序改变不会影响用户已经保存的配置
    case custom = -1, smms = 1, upyun_USS = 3, qiniu_KODO = 2, aliyun_OSS = 4, tencent_COS = 5, github = 6, gitee = 7, weibo = 8, amazon_S3 = 9, imgur = 10, baidu_BOS = 11

    public var name: String {
        get {
            return NSLocalizedString("host.type.\(self.rawValue)", comment: "")
        }
    }
}
