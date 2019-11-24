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
}
