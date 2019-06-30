//
//  WeiboqQuality.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation


public enum WeiboqQuality: String, CaseIterable {
    case thumbnail, mw690, large

    public var name: String {
        get {
            return NSLocalizedString("weibo.quality.\(self.rawValue)", comment: "")
        }
    }
}
