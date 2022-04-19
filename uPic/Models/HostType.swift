//
//  HostType.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/15.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public enum HostType: String, CaseIterable, Codable {
    case custom
    case smms
    case qiniu_kodo
    case upyun_uss
    case aliyun_oss
    case tencent_cos
    case github
    case gitee
    case weibo
    case s3
    case imgur
    case baidu_bos
    case lsky_pro
    case coding
    
    public init(intValue: Int) {
        switch intValue {
        case -1:
            self = .custom
        case 1:
            self = .smms
        case 2:
            self = .qiniu_kodo
        case 3:
            self = .upyun_uss
        case 4:
            self = .aliyun_oss
        case 5:
            self = .tencent_cos
        case 6:
            self = .github
        case 7:
            self = .gitee
        case 8:
            self = .weibo
        case 9:
            self = .s3
        case 10:
            self = .imgur
        case 11:
            self = .baidu_bos
        case 12:
            self = .lsky_pro
        case 13:
            self = .coding
        default:
            self = .smms
        }
    }
    

    public var name: String {
        get {
            return NSLocalizedString("host.type.\(self.rawValue)", comment: "")
        }
    }
}
