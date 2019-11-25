//
//  HistoryPreviewCustomScrollView.swift
//  uPic
//
//  Created by 侯猛 on 2019/11/25.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class HistoryPreviewCustomScrollView: NSScrollView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}
