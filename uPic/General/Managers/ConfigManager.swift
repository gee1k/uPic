//
//  CoreManager.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class ConfigManager {
    
    // static
    public static var shared = ConfigManager()
    
    // instance
    
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
        // 提前取出图床配置
        let hostItems = self.getHostItems()
        let domain = Bundle.main.bundleIdentifier!
        Defaults.removePersistentDomain(forName: domain)
        // 清除所有用户设置后，再重新写入图床配置
        self.setHostItems(items: hostItems)
        Defaults.synchronize()
    }
    
    func getHostItems() -> [Host] {
        return Defaults[.hostItems] ?? [Host]()
    }
    
    func setHostItems(items: [Host]) -> Void {
        Defaults[.hostItems] = items
        ConfigNotifier.postNotification(.changeHostItems)
    }
    
    
    func getDefaultHost() -> Host? {
        guard let defaultHostId = Defaults[.defaultHostId], let hostItems = Defaults[.hostItems] else {
            return nil
        }
        for host in hostItems {
            if host.id == defaultHostId {
                return host
            }
        }
        return nil
    }
    
}
