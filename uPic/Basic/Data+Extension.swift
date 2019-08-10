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
    
    // 转换图片格式
    func convertImageData(_ fileType: NSBitmapImageRep.FileType = .png) -> Data? {
        let bitmap = NSBitmapImageRep(data: self)
        let data = bitmap?.representation(using: fileType, properties: [:])
        return data
    }
    
    /**
     压缩图片，只支持压缩图片，压缩之后图片格式是 jpg。
     gif，以及其他非图片均不能压缩
     factor: 压缩率 0~1
     */
    func compressImage(_ factor: Float = 0.7) -> Data {
        guard let bitmap = NSBitmapImageRep(data: self) else {
            return self
        }
        if (factor > 0.0 && factor < 1.0 && self.contentType() != "gif" && bitmap.canBeCompressed(using: .jpeg)) {
            let repData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: factor])
            return repData ?? self
        }
        return self
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
    
    func contentBitmapType() -> NSBitmapImageRep.FileType? {
        let c = self.bytes.first
        
        switch c {
        case 0xFF:
            return .jpeg
        case 0x89:
            return .png
        case 0x47:
            return .gif
        case 0x49:
            return .jpeg
        case 0x4D:
            return .jpeg
        default:
            return nil
        }
        
    }
}
