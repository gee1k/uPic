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
                return NSLocalizedString("save-key.filename", comment: "filename")
            case .random:
                return NSLocalizedString("save-key.random", comment: "random")
            case .dateFilename:
                return NSLocalizedString("save-key.date-filename", comment: "date-filename")
            case .datetimeFilename:
                return NSLocalizedString("save-key.datetime-filename", comment: "datetime-filename")
            case .secondFilename:
                return NSLocalizedString("save-key.second-filename", comment: "second-filename")
            case .millisecondFilename:
                return NSLocalizedString("save-key.millisecond-filename", comment: "millisecond-filename")
            case .dateRandom:
                return NSLocalizedString("save-key.date-random", comment: "date-random")
            case .datetimeRandom:
                return NSLocalizedString("save-key.datetime-random", comment: "datetime-random")
            case .secondRandom:
                return NSLocalizedString("save-key.second-random", comment: "second-random")
            case .millisecondRandom:
                return NSLocalizedString("save-key.millisecond-random", comment: "millisecond-random")
            }
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
