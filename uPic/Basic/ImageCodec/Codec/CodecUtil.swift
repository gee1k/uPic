//
// Created by Bq Lin on 2021/5/19.
// Copyright (c) 2021 Bq. All rights reserved.
//

import Foundation
import CoreGraphics

class CodecUtil {
    typealias SizeTuple<T> = (width: T, height: T)
    typealias SizeTupleOptional<T> = (width: T?, height: T?)
    
    static func sizeLimited(src: SizeTupleOptional<Int>? = nil, des: SizeTupleOptional<Int>) -> Bool {
        if let value = des.width, value > 0 {
            if let src = src?.width {
                if src > value { return true }
            } else {
                return true
            }
        }
        if let value = des.height, value > 0 {
            if let src = src?.height {
                if src > value { return true }
            } else {
                return true
            }
        }
        return false
    }
    
    static func convertedSize(src: SizeTuple<Int>, des: SizeTupleOptional<Int>) -> SizeTuple<Int> {
        var size = src
        if let maxWidth = des.width, size.width > maxWidth {
            size.width = maxWidth
            let value = Double(size.width) / Double(src.width) * Double(src.height)
            size.height = Int(value)
        }
        if let maxHeight = des.height, size.height > maxHeight {
            size.height = maxHeight
            let value = Double(size.height) / Double(src.height) * Double(src.width)
            size.width = Int(value)
        }
        return size
    }
}
