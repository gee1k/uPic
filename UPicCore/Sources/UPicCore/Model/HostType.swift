//
//  HostType.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import HandyJSON

public enum HostType: String, CaseIterable, HandyJSONEnum {
    case smms
    case weibo
    case imgur
    case s3
    case qiniu_kodo
    case upyun_uss
    case aliyun_oss
    case tencent_cos
    case baidu_bos
    case github
    case gitee
    case custom

    public var displayNname: String {
        switch self {
            case .smms: return String(localized: "SMMS", bundle: .module)
            case .weibo: return String(localized: "Weibo", bundle: .module)
            case .imgur: return String(localized: "Imgur", bundle: .module)
            case .s3: return String(localized: "Amazon S3 Compatible", bundle: .module)
            case .qiniu_kodo: return String(localized: "Qiniu KODO", bundle: .module)
            case .upyun_uss: return String(localized: "Upyun USS", bundle: .module)
            case .aliyun_oss: return String(localized: "Aliyun OSS", bundle: .module)
            case .tencent_cos: return String(localized: "Tencent Cloud COS", bundle: .module)
            case .baidu_bos: return String(localized: "Baidu Cloud BOS", bundle: .module)
            case .github: return String(localized: "GitHub", bundle: .module)
            case .gitee: return String(localized: "Gitee", bundle: .module)
            case .custom: return String(localized: "Custom", bundle: .module)
        }
    }
}
