//
//  String+Extension.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/16.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoSwift

extension String {

    func toBytes() -> Array<UInt8> {
        return self.bytes
    }

    func toMd5() -> String {
        return self.md5()
    }

    func toBase64() -> String {
        return self.bytes.toBase64()!
    }

    func toSha1() -> String {
        return self.sha1()
    }

    func toSha224() -> String {
        return self.sha224()
    }

    func toSha256() -> String {
        return self.sha256()
    }

    func toSha384() -> String {
        return self.sha384()
    }

    func toSha512() -> String {
        return self.sha512()
    }

    func calculateHMACByKey(key: String) -> Array<UInt8> {
        let hmac = try! HMAC(key: key.toBytes(), variant: .sha1).authenticate(self.toBytes())
        return hmac
    }
    
    func calculateHMAC256ByKey(key: Array<UInt8>) -> Array<UInt8> {
        let hmac = try! HMAC(key: key, variant: .sha256).authenticate(self.toBytes())
        return hmac
    }

    func urlSafeBase64() -> String {
        return self.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
    }
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // 字符串增强
    var isAbsolutePath: Bool {
        return (self as NSString).isAbsolutePath
    }
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    var pathComponents: [String] {
        return (self as NSString).pathComponents
    }

    func appendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }

    func appendingPathExtension(ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.appendingPathExtension(ext)
    }
    
    func getFileTypeByPathExtension() -> NSBitmapImageRep.FileType? {
        switch self.pathExtension {
        case "png":
            return NSBitmapImageRep.FileType.png
        case "jpg":
            return NSBitmapImageRep.FileType.jpeg
        case "jpeg":
            return NSBitmapImageRep.FileType.jpeg
        case "gif":
            return NSBitmapImageRep.FileType.gif
        case "bmp":
            return NSBitmapImageRep.FileType.bmp
        default:
            return nil
        }
    }


    static let random_str_characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

    static func randomStr(len: Int) -> String {
        var ranStr = ""
        for _ in 0..<len {
            let index = Int(arc4random_uniform(UInt32(random_str_characters.count)))
            ranStr.append(random_str_characters[random_str_characters.index(random_str_characters.startIndex, offsetBy: index)])
        }
        return ranStr
    }
}
