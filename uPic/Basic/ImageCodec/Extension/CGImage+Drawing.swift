//
// Created by Bq Lin on 2021/5/18.
// Copyright (c) 2021 Bq. All rights reserved.
//

import Foundation
import CoreGraphics

struct TypeWrapper<Base: AnyObject> {
    let base: Base
    
    init(_ base: Base) { self.base = base }
}

protocol Drawable: AnyObject {
    associatedtype Base: AnyObject
    static var draw: TypeWrapper<Base>.Type { get }
    var draw: TypeWrapper<Base> { get }
}

extension Drawable {
    static var draw: TypeWrapper<Self>.Type { TypeWrapper<Self>.self }
    var draw: TypeWrapper<Self> { TypeWrapper(self) }
}

extension CGImage: Drawable {}

extension TypeWrapper where Base: CGImage {
    func makeImage(backgroundColor: CGColor) -> CGImage? {
        let canvas = makeCanvas()
        canvas.setFillColor(backgroundColor)
        let rect = self.rect
        canvas.fill(rect)
        canvas.draw(base, in: rect)
        
        return canvas.makeImage()
    }
    
    func makeImage(toSize: CodecUtil.SizeTuple<Int>) -> CGImage? {
        let canvas = makeCanvas(size: toSize)
        canvas.draw(base, in: CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        
        return canvas.makeImage()
    }
    
    func makeCanvas(size: CodecUtil.SizeTuple<Int>? = nil, hasAlpha: Bool? = nil) -> CGContext {
        let width = size?.width ?? base.width
        let height = size?.height ?? base.height
        
        var canvas: CGContext?
        if hasAlpha == nil {
            canvas = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: base.bitsPerComponent,
                bytesPerRow: 0,
                space: base.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: base.bitmapInfo.rawValue
            )
        }
        
        let hasAlpha = hasAlpha ?? self.hasAlpha
        // let components = hasAlpha ? 4 : 3
        var bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= hasAlpha ? CGImageAlphaInfo.premultipliedFirst.rawValue : CGImageAlphaInfo.noneSkipFirst.rawValue
        if canvas == nil {
            canvas = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: bitmapInfo
            )
        }
        
        canvas?.setShouldAntialias(true)
        canvas?.setAllowsAntialiasing(true)
        canvas?.interpolationQuality = .high
        
        return canvas!
    }
    
    var rect: CGRect {
        CGRect(x: 0, y: 0, width: base.width, height: base.height)
    }
    
    var hasAlpha: Bool {
        switch base.alphaInfo {
            case .premultipliedLast, .premultipliedFirst, .last, .first:
                return true
            default:
                return false
        }
    }
}

