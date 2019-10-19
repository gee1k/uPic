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
