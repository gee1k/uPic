//
//  HostFileKey.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/15.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation


public enum HostSaveKey: String, CaseIterable, Codable {
    case dateFilename, datetimeFilename, filename, random

    public var name: String {
        get {
            switch self {
            case .filename:
                return NSLocalizedString("save-key.filename", comment: "filename")
            case .dateFilename:
                return NSLocalizedString("save-key.date-filename", comment: "date-filename")
            case .datetimeFilename:
                return NSLocalizedString("save-key.datetime-filename", comment: "datetime-filename")
            case .random:
                return NSLocalizedString("save-key.random", comment: "random")
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
        case .dateFilename:
            return "\(Date().format(dateFormat: "yyyy-MM-dd"))-\(filename!)"
        case .datetimeFilename:
            return "\(Date().format(dateFormat: "yyyy-MM-dd-HH:mm:ss"))-\(filename!)"
        case .random:
            return String.randomStr(len: 6)
        }
    }
}
