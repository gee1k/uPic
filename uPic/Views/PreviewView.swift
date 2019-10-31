//
//  HistoryViewController.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/22.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class PreviewView: NSView {
    
    private(set) var imageView: NSImageView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initializeView()
    }
    
    func initializeView() {
        imageView = NSImageView()
        addSubview(imageView)
    }
    
    override func layout() {
        super.layout()
        imageView.frame = bounds
    }
    
}
