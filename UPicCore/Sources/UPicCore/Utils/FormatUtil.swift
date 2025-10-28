//
//  FormatUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

internal class FormatUtil {
    
    static func _getRandomFileName(_ fileExtension: String?) -> String {
        let random = String.randomStr(len: 6)
        guard let fileExtension = fileExtension else {
            return random
        }
        return "\(random).\(fileExtension)"
    }
    
    /// 格式化文件保存路径为完整的路径
    /// - Parameters:
    ///   - saveKeyPath: 文件保存路径（含变量）
    ///   - filenameComponent: 文件名,含后缀
    static func parseSaveKeyPath(_ saveKeyPath: String?, _ filenameComponent: String) -> String {
        let keyPath = (saveKeyPath != nil && !saveKeyPath!.isEmpty) ? saveKeyPath! : UPicCoreConstants.DEFAULT_SAVE_KEY_PATH
        return _parseVariables(keyPath, filenameComponent, otherVariables: nil)
    }
    
    /// 转换字符串中的变量
    /// - Parameters:
    ///   - str: 字符串（含变量）
    ///   - filenameComponent: 文件名,含后缀
    ///   - otherVariables: 额外变量及值 （变量名：value）
    static func _parseVariables(_ str: String, _ filenameComponent: String, otherVariables: [String: String]?) -> String {
        if str.isEmpty {
            return str
        }
        
        let filename = filenameComponent.lastPathComponent.deletingPathExtension
        let fileExtension = filenameComponent.pathExtension
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let second = calendar.component(.second, from: now)
        // The number of seconds since 1970
        let sinceSecond = now.secondStamp
        // The number of millisecond since 1970
        let sinceMillisecond = now.millisecondStamp
        
        var result = str.replacingOccurrences(of: "{year}", with: "\(year)")
                        .replacingOccurrences(of: "{month}", with: _padZero(month))
                        .replacingOccurrences(of: "{day}", with: _padZero(day))
                        .replacingOccurrences(of: "{hour}", with: _padZero(hour))
                        .replacingOccurrences(of: "{minute}", with: _padZero(minute))
                        .replacingOccurrences(of: "{second}", with: _padZero(second))
                        .replacingOccurrences(of: "{since_second}", with: "\(sinceSecond)")
                        .replacingOccurrences(of: "{since_millisecond}", with: "\(sinceMillisecond)")
                        .replacingOccurrences(of: "{filename}", with: filename)
                        .replacingOccurrences(of: "{random}", with: _getRandomFileName(nil))
                        .replacingOccurrences(of: "{.suffix}", with: ".\(fileExtension)")
        
        if let variables = otherVariables, variables.count > 0 {
            for (key, value) in variables {
                result = result.replacingOccurrences(of: "{\(key)}", with: value)
            }
        }
        
        return result
    }
    
    private static func _padZero(_ num: Int) -> String {
        return num < 10 ? "0\(num)" : "\(num)"
    }
}
