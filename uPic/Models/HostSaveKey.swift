//
//  HostFileKey.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/15.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation


public enum HostSaveKey: String, CaseIterable, Codable {
    case dateFilename, filename, random

    public var name: String {
        get {
            switch self {
            case .filename:
                return "文件名"
            case .dateFilename:
                return "日期-文件名"
            case .random:
                return "随机"
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
        case .random:
            return String.randomStr(len: 6)
        }
    }
}
