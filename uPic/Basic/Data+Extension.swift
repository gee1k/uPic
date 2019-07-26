//
//  Data+Extension.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/16.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import CryptoSwift

extension Data {

    func toBytes() -> Array<UInt8> {
        return self.bytes
    }

    func toMd5() -> String {
        return self.md5().toHexString()
    }

    func toBase64() -> String {
        return self.bytes.toBase64()!
    }

    func toSha1() -> String {
        return self.sha1().toHexString()
    }

    func toSha224() -> String {
        return self.sha224().toHexString()
    }

    func toSha256() -> String {
        return self.sha256().toHexString()
    }

    func toSha384() -> String {
        return self.sha384().toHexString()
    }

    func toSha512() -> String {
        return self.sha512().toHexString()
    }
    
    func toString() -> String {
        return String(data: self, encoding: .utf8)!
    }
    
    func convertImageDataToJpg() -> Data? {
        let bitmap = NSBitmapImageRep(data: self)
        let jpg = bitmap?.representation(using: .jpeg, properties: [:])
        return jpg
    }
    
    func convertImageDataToPng() -> Data? {
        let bitmap = NSBitmapImageRep(data: self)
        let png = bitmap?.representation(using: .png, properties: [:])
        return png
    }
    
    func contentType() -> String? {
        let c = self.bytes.first
        
        switch c {
        case 0xFF:
            return "jpg"
        case 0x89:
            return "png"
        case 0x47:
            return "gif"
        case 0x49:
            return "tiff"
        case 0x4D:
            return "tiff"
        default:
            return nil
        }
        
    }
    
}
