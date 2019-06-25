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
    case smms = 1, upyun_USS = 3, qiniu_KODO = 2, aliyun_OSS = 4, tencent_COS = 5

    public var name: String {
        get {
            return NSLocalizedString("host.type.\(self.rawValue)", comment: "")
        }
    }

    public var isOnlyOne: Bool {
        get {
            switch self {
            case .smms:
                return true
            default:
                return false
            }
        }
    }

}
