//
//  HostFileKey.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/15.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation


public enum HostSaveKey: String, CaseIterable, Codable {
    case filename, random, dateFilename, datetimeFilename, secondFilename, millisecondFilename, dateRandom, datetimeRandom, secondRandom, millisecondRandom

    public var name: String {
        get {
            switch self {
            case .filename:
                return "filename".localized
            case .random:
                return "random".localized
            case .dateFilename:
                return "date-filename".localized
            case .datetimeFilename:
                return "datetime-filename".localized
            case .secondFilename:
                return "second-filename".localized
            case .millisecondFilename:
                return "millisecond-filename".localized
            case .dateRandom:
                return "date-random".localized
            case .datetimeRandom:
                return "datetime-random".localized
            case .secondRandom:
                return "second-random".localized
            case .millisecondRandom:
                return "millisecond-random".localized
            }
        }
    }
    
    // FIXME: 临时处理 filename 的数据到新版的 saveKey 中。后续版本需要移除
    public func _getSaveKeyPathPattern() -> String {
        switch self {
        case .filename:
            return "{filename}{.suffix}"
        case .random:
            return "{random}{.suffix}"
        case .dateFilename:
            return "{year}-{mon}-{day}-{filename}{.suffix}"
        case .datetimeFilename:
            return "{year}{mon}{day}{hours}{minutes}{seconds}-{filename}{.suffix}"
        case .secondFilename:
            return "{since_seconds}-{filename}{.suffix}"
        case .millisecondFilename:
            return "{since_milliseconds}-{filename}{.suffix}"
        case .dateRandom:
            return "{year}-{mon}-{day}-{random}{.suffix}"
        case .datetimeRandom:
            return "{year}{mon}{day}{hours}{minutes}{seconds}-{random}{.suffix}"
        case .secondRandom:
            return "{since_seconds}-{random}{.suffix}"
        case .millisecondRandom:
            return "{since_milliseconds}-{random}{.suffix}"
        }
    }

    public func getFileName(filename: String? = nil) -> String {
        var filename = filename
        if filename == nil {
            filename = String.randomStr(len: 6)
        }

        switch self {
        case .filename:
            return filename!
        case .random:
            return String.randomStr(len: 6)
        case .dateFilename:
            return "\(Date().format(dateFormat: "yyyy-MM-dd"))-\(filename!)"
        case .datetimeFilename:
            return "\(Date().format(dateFormat: "yyyyMMddHHmmss"))-\(filename!)"
        case .secondFilename:
            return "\(Date().timeStamp)-\(filename!)"
        case .millisecondFilename:
            return "\(Date().milliStamp)-\(filename!)"
        case .dateRandom:
            return "\(Date().format(dateFormat: "yyyy-MM-dd"))-\(String.randomStr(len: 6))"
        case .datetimeRandom:
            return "\(Date().format(dateFormat: "yyyyMMddHHmmss"))-\(String.randomStr(len: 6))"
        case .secondRandom:
            return "\(Date().timeStamp)-\(String.randomStr(len: 6))"
        case .millisecondRandom:
            return "\(Date().milliStamp)-\(String.randomStr(len: 6))"
        }
    }
}
