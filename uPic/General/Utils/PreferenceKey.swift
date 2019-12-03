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
    static let hostItems = "uPic_hostItems"
    static let defaultHostId = "uPic_DefaultHostId"
    static let ouputFormat = "uPic_OutputFormat"
    static let historyList = "uPic_HistoryList_New"
    static let historyLimit = "uPic_HistoryLimit_New"
    static let compressFactor = "uPic_CompressFactor"
    // historyRecord
    static let historyRecordWidth = "uPic_HistoryRecordWidth"
    static let historyRecordColumns = "uPic_HistoryRecordColumns"
    static let historyRecordSpacing = "uPic_HistoryRecordSpacing"
    static let historyRecordPadding = "uPic_HistoryRecordPadding"
    static let historyRecordFileNameScrollSpeed = "uPic_HistoryRecordFileNameScrollSpeed"
    static let historyRecordFileNameScrollWaitTime = "uPic_HistoryRecordFileNameScrollWaitTime"
}

class DefaultsKeys {
    fileprivate init() {
    }
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
    static let hostItems = DefaultsKey<[Host]>(Keys.hostItems)
    static let defaultHostId = DefaultsKey<Int>(Keys.defaultHostId)
    static let ouputFormat = DefaultsKey<Int>(Keys.ouputFormat)
    static let historyList = DefaultsKey<[[String: Any]]>(Keys.historyList)
    static let historyLimit = DefaultsKey<Int>(Keys.historyLimit)
    static let compressFactor = DefaultsKey<Int>(Keys.compressFactor)
    static let historyRecordWidth = DefaultsKey<Float>(Keys.historyRecordWidth)
    static let historyRecordColumns = DefaultsKey<Int>(Keys.historyRecordColumns)
    static let historyRecordSpacing = DefaultsKey<Float>(Keys.historyRecordSpacing)
    static let historyRecordPadding = DefaultsKey<Float>(Keys.historyRecordPadding)
    static let historyRecordFileNameScrollSpeed = DefaultsKey<Double>(Keys.historyRecordFileNameScrollSpeed)
    static let historyRecordFileNameScrollWaitTime = DefaultsKey<Float>(Keys.historyRecordFileNameScrollWaitTime)

}

let Defaults = UserDefaults.standard

extension UserDefaults {
    subscript(key: DefaultsKey<String>) -> String? {
        get {
            return string(forKey: key._key)
        }
        set {
            set(newValue, forKey: key._key)
        }
    }

    subscript(key: DefaultsKey<Int>) -> Int? {
        get {
            return integer(forKey: key._key)
        }
        set {
            set(newValue, forKey: key._key)
        }
    }
    
    subscript(key: DefaultsKey<Double>) -> Double? {
        get {
            return double(forKey: key._key)
        }
        set {
            set(newValue, forKey: key._key)
        }
    }
    
    subscript(key: DefaultsKey<Float>) -> Float? {
        get {
            return float(forKey: key._key)
        }
        set {
            set(newValue, forKey: key._key)
        }
    }

    subscript(key: DefaultsKey<[Host]>) -> [Host]? {
        get {
            var result = [Host]()
            if let arr = array(forKey: key._key) {
                for item in arr {
                    let str = item as! String
                    let host = Host.deserialize(str: str)
                    if host != nil {
                        result.append(host!)
                    }
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
    
    subscript(key: DefaultsKey<[String]>) -> [String]? {
        get {
            return array(forKey: key._key) as? [String]
        }
        set {
            set(newValue, forKey: key._key)
        }
    }
    
    subscript(key: DefaultsKey<[[String: Any]]>) -> [[String: Any]]? {
        get {
            return array(forKey: key._key) as? [[String: Any]]
        }
        set {
            set(newValue, forKey: key._key)
        }
    }
}
