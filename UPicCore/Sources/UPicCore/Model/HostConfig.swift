//
//  HostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import HandyJSON

@objcMembers
public class HostConfig: NSObject, HandyJSON {
    override public required init() {}

    public func isValid() -> Bool {
        return true
    }

    public static func create(_ hostType: HostType) -> HostConfig {
        switch hostType {
        case .aliyun_oss:
            return AliyunHostConfig()
        case .s3:
            return S3HostConfig()
        case .baidu_bos:
            return BaiduHostConfig()
        case .custom:
            return CustomHostConfig()
        case .gitee:
            return GiteeHostConfig()
        case .github:
            return GithubHostConfig()
        case .imgur:
            return ImgurHostConfig()
        case .qiniu_kodo:
            return QiniuHostConfig()
        case .smms:
            return SmmsHostConfig()
        case .tencent_cos:
            return TencentHostConfig()
        case .upyun_uss:
            return UpyunHostConfig()
        case .weibo:
            return WeiboHostConfig()
        }
    }
}
