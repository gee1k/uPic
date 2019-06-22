//
//  PreferenceKey.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/13.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

struct Keys {
    static let firstUsage = "uPic_FirstUsage"
    static let launchAtLogin = "uPic_LaunchAtLogin"
    static let hostItems = "uPic_hostItems"
    static let defaultHostId = "uPic_DefaultHostId"
    static let ouputFormat = "uPic_OutputFormat"
}

class DefaultsKeys {
    fileprivate init() {}
}

class DefaultsKey<ValueType>: DefaultsKeys {
    let _key: String
    
    init(_ key: String) {
        self._key = key
    }
    
}


extension DefaultsKeys {
    
    // The values corresponding to the following keys are String.
    
    // value example: BoolType._true.rawValue
    static let firstUsage = DefaultsKey<String>(Keys.firstUsage)
    static let launchAtLogin = DefaultsKey<String>(Keys.launchAtLogin)
    static let hostItems = DefaultsKey<[Host]>(Keys.hostItems)
    static let defaultHostId = DefaultsKey<Int>(Keys.defaultHostId)
    static let ouputFormat = DefaultsKey<Int>(Keys.ouputFormat)
    
}

let Defaults = UserDefaults.standard

extension UserDefaults {
    subscript(key: DefaultsKey<String>) -> String? {
        get { return string(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    
    subscript(key: DefaultsKey<Int>) -> Int? {
        get { return integer(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    
    subscript(key: DefaultsKey<[Host]>) -> [Host]? {
        get {
            var result = [Host]()
            if let arr = array(forKey: key._key) {
                for item in arr {
                    let str = item as! String
                    let host = Host.deserialize(str: str)
                    result.append(host)
                }
            }
            return result
        }
        set {
            var result = [String]()
            if let arr = newValue {
                for item in arr {
                    let encodedString = item.serialize()
                    result.append(encodedString)
                }
            }
            set(result, forKey: key._key)
        }
    }
}
