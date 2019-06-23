//
//  HostType.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/15.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public enum HostType: Int, CaseIterable, Codable {
    // MARK: 
    case smms = 1, upyun_USS = 3, qiniu_KODO = 2//, aliyun_OSS, tencent_COS
    
    public var name: String {
        get {
            switch self {
            case .smms:
                return "SMMS"
            case .upyun_USS:
                return "又拍云USS"
            case .qiniu_KODO:
                return "七牛云KODO"
//            case .aliyun_OSS:
//                return "阿里云OSS"
//            case .tencent_COS:
//                return "腾讯云COS"
            }
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
