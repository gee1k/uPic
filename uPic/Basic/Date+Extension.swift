//
//  Date+Extension.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/13.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

extension Date {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp: Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return timeStamp
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp: CLongLong {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval * 1000))
        return millisecond
    }
    
    func toGMT() -> String {
        let formatter = DateFormatter()
        // GMT:
        // E, dd, MM yyyy HH:mm:ss zzz
        formatter.dateFormat = "E, dd, MM yyyy HH:mm:ss zzz"
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.locale = Locale(identifier: "GMT")
        return formatter.string(from: self)
    }
    
    func format(dateFormat: String? = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}
