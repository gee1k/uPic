//
//  SmmsVersion.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//
import Foundation

enum SmmsVersion: String, CaseIterable {
    case v1
    case v2
    
    public var name: String {
        get {
            return NSLocalizedString("smms.version.\(self.rawValue)", comment: "")
        }
    }
}
