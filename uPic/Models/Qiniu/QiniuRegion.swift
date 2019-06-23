//
//  QiniuRegion.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public enum QiniuRegion: String, CaseIterable {
    case z0
    case z1
    case z2
    case na0
    case as0
    
    public var name: String {
        get {
            switch self {
            case .z0:
                return "华东"
            case .z1:
                return "华北"
            case .z2:
                return "华南"
            case .na0:
                return "北美"
            case .as0:
                return "东南亚"
            }
        }
    }
    
    public var url: String {
        get {
            switch self {
            case .z0:
                return "https://upload.qiniup.com"
            case .z1:
                return "https://upload-z1.qiniup.com"
            case .z2:
                return "https://upload-z2.qiniup.com"
            case .na0:
                return "https://upload-na0.qiniup.com"
            case .as0:
                return "https://upload-as0.qiniup.com"
            }
        }
    }
}
