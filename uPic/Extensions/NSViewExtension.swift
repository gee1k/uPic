//
//  NSViewExtension.swift
//  uPic
//
//  Created by 侯猛 on 2019/11/1.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Foundation

extension NSView {
    
    func insertVibrancyViewBlendingMode(model: NSVisualEffectView.BlendingMode) {
        let vibrant = NSVisualEffectView(frame: bounds)
        vibrant.blendingMode = model
        vibrant.state = .active
        addSubview(vibrant)
//        addSubview(vibrant, positioned: .below, relativeTo: nil)
    }
}
