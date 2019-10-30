//
//  VerticalCenteringCell.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class VerticalCenteringCell: NSTextFieldCell {
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        var newRect: NSRect = super.drawingRect(forBounds: rect)
        let textSize: NSSize = cellSize(forBounds: rect)
        let heightDelta: CGFloat = newRect.size.height - textSize.height
        guard heightDelta > 0 else { return newRect }
        newRect.size.height = textSize.height
        newRect.origin.y += heightDelta * 0.5
        return newRect
    }

}
