//
//  FlippedView.swift
//  uPic
//
//  Created by Svend Jin on 2019/7/17.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class FlippedView: NSView {
    override var isFlipped:Bool {
        get {
            return true
        }
    }
}
