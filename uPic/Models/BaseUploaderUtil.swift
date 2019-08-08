//
//  BaseUploaderUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/8/8.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

class BaseUploaderUtil {
    static func compressImage(_ data: Data) -> Data {
        var factor:Int = ConfigManager.shared.compressFactor
        
        if factor >= 100 {
            return data
        }
        
        // 压缩图片
        debugPrint("origin data -> \(data.bytes.count)")
        let retData = data.compressImage(Float(factor) / 100)
        debugPrint("compress data -> \(retData.bytes.count)")
        return retData
    }
    
    static func compressImage(_ url: URL) -> Data? {
        var factor:Int = ConfigManager.shared.compressFactor
        
        if factor >= 100 {
            return nil
        }
        
        let data = try? Data(contentsOf: url)
        // 压缩图片
        debugPrint("origin data -> \(data?.bytes.count)")
        let retData = data?.compressImage(Float(factor) / 100)
        debugPrint("compress data -> \(retData?.bytes.count)")
        return retData
    }
}
