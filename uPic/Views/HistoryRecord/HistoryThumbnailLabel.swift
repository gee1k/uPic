//
//  HistoryThumbnailLabel.swift
//  uPic
//
//  Created by 侯猛 on 2019/11/26.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class HistoryThumbnailLabel: NSView {

    private(set) var fileName: NSTextField!
    
    var stringValue: String = "" {
        didSet {
            fileName.stringValue = stringValue
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        fileName = NSTextField()
        fileName.cell = VerticalCenteringCell()
        fileName.backgroundColor = NSColor.clear
        fileName.canDrawSubviewsIntoLayer = true
        fileName.alignment = .center
        fileName.isEditable = false
        fileName.appearance = NSAppearance(named: NSAppearance.Name.aqua)
        fileName.textColor = NSColor.white
        addSubview(fileName)
        
        
        fileName.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


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
