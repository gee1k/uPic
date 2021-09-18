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
    
    var pngData: Data? {
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
}

extension NSImage {

}
