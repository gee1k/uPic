//
//  NSImageExtension.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Foundation

extension NSImage {
    func resizeImage(size: NSSize) -> NSImage {
        let targetFrame = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        let sourceImageRep = self.bestRepresentation(for: targetFrame, context: nil, hints: nil)
        let targetImage = NSImage(size: size)
        targetImage.lockFocus()
        sourceImageRep?.draw(in: targetFrame)
        targetImage.unlockFocus()
        return targetImage
    }

    func pngData() -> Data? {
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: NSColorSpaceName.deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            print("Couldn't create bitmap representation")
            return nil
        }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        draw(at: NSZeroPoint, from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        guard let data = rep.representation(using: NSBitmapImageRep.FileType.png, properties: [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]) else {
            print("Couldn't create PNG")
            return nil
        }
        return data
    }

    /// 将NSImage转换为JPEG数据
    func jpegData(compressionQuality: CGFloat = 0.9) -> Data? {
        guard let tiffData = tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData)
        else {
            return nil
        }
        return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
}
