//
//  StringExtension.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

internal extension String {
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var lastPathComponent: String {
        return NSString(string: self).lastPathComponent
    }
    
    var deletingLastPathComponent: String {
        return NSString(string: self).deletingLastPathComponent
    }
    
    var deletingPathExtension: String {
        return NSString(string: self).deletingPathExtension
    }
    
    var pathExtension: String {
        return NSString(string: self).pathExtension
    }
    
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    func urlSafeBase64() -> String {
        return self.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
    }
    
    private static let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

    static func randomStr(len: Int) -> String {
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
}
