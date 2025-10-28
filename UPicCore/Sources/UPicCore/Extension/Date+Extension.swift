//
//  DateExtension.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

internal extension Date {
    
    var secondStamp: Int {
        return Int(self.timeIntervalSince1970)
    }
    
    var millisecondStamp: CLongLong {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        return CLongLong(round(timeInterval*1000))
    }
    
    func toUTCString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
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
}
