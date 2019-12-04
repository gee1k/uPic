//
//  BaseUploaderUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/8/8.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import libminipng

class BaseUploaderUtil {
    
    
    /// 压缩PNG图片。
    /// - Parameters:
    ///   - data: jpg Data
    ///   - factor: 压缩率 0~100
    private static func compressPng(_ data: Data, factor: Int = 100) -> Data {
        if (factor <= 0 || factor >= 100) {
           return data
        }
        
        let repData = minipng.data2Data(data, factor)

        return repData ?? data
    }
    
    /// 压缩Jpg图片。
    /// - Parameters:
    ///   - data: jpg Data
    ///   - factor: 压缩率 0~100
    private static func compressJpg(_ data: Data, factor: Int = 100) -> Data {
        guard let bitmap = NSBitmapImageRep(data: data) else {
            return data
        }
        
        let factor = Float(factor) / 100
        
        if (factor <= 0.0 || factor >= 1.0) {
            return data
        }
        
        // && self.contentType() != "gif" && bitmap.canBeCompressed(using: .jpeg)
        
        let repData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: factor])
        return repData ?? data
    }
    
    static func _compressImage(_ data: Data) -> Data {
        let factor:Int = ConfigManager.shared.compressFactor
        
        if factor >= 100 {
            return data
        }
        
        let contentType = data.contentType()
        switch contentType {
        case "png":
            return compressPng(data, factor: factor)
        case "jpg":
            return compressJpg(data, factor: factor)
        default:
            return data
        }
    }
    
    static func compressImage(_ data: Data) -> Data {
        let retData = _compressImage(data)
        return retData
    }
    
    static func compressImage(_ url: URL) -> Data? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        let retData = _compressImage(data)
        return retData
    }
}
