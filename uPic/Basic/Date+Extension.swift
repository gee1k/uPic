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

    func format(dateFormat: String? = "yyyy-MM-dd HH:mm:ss", timeZone: TimeZone? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        if timeZone != nil {
            formatter.timeZone = timeZone!
        }
        return formatter.string(from: self)
    }
    
    func toISOString(dateFormat: String? = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> String {
        return Date.ISOStringFromDate(date: self, dateFormat: dateFormat)
    }
    
    static func ISOStringFromDate(date: Date, dateFormat: String? = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: date)
    }
    
    static func dateFromISOString(string: String, dateFormat: String? = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.date(from: string)
    }
    
}
