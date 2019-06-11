//
//  CoreManager.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class CoreManager {
    
    public static var shared = CoreManager()
    
    
    
    public var firstUsage: BoolType {
        if Defaults[.firstUsage] == nil {
            Defaults[.firstUsage] = BoolType._false.rawValue
            return ._true
        } else {
            return ._false
        }
    }
    
    public var launchAtLogin: BoolType? {
        get {
            return Defaults[.launchAtLogin].map(BoolType.init(rawValue: )) ?? nil
        }
        
        set {
            Defaults[.launchAtLogin] = newValue?.rawValue
        }
    }
    
    
    public func firstSetup() {
        guard firstUsage == ._true else { return }
        Defaults[.launchAtLogin] = BoolType._false.rawValue
        Defaults.synchronize()
    }
    
    public func removeAllUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        Defaults.removePersistentDomain(forName: domain)
        Defaults.synchronize()
    }
    
}
