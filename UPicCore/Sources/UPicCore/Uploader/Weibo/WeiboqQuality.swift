//
//  WeiboqQuality.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import HandyJSON

public enum WeiboqQuality: String, CaseIterable, HandyJSONEnum {
    case thumbnail, mw690, large

    public var displayName: String {
        switch self {
            case .thumbnail: return String(localized: "Thumbnail")
            case .mw690: return String(localized: "Medium")
            case .large: return String(localized: "Original")
        }
    }
}
