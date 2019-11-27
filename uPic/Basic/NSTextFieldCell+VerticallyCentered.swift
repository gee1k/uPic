//
//  NSTextFieldCell+VerticallyCentered.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/13.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

// 垂直居中
class VerticallyCenteredTextFieldCell: NSTextFieldCell {

    override func drawingRect(forBounds theRect: NSRect) -> NSRect {
        var newRect: NSRect = super.drawingRect(forBounds: theRect)
        let textSize: NSSize = self.cellSize(forBounds: theRect)
        let heightDelta: CGFloat = newRect.size.height - textSize.height
        if heightDelta > 0 {
            newRect.size.height -= heightDelta
            newRect.origin.y += heightDelta / 2
        }
        return newRect
    }

}
