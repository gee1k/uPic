//
//  Public.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

func setNextKeyViews(nextKeyViews: [NSView]) {
    if nextKeyViews.count > 1 {
        for (index, item) in nextKeyViews.enumerated() {
            let currentView = item
            if index == nextKeyViews.count - 1 {
                break
            }
            
            let nextView = nextKeyViews[index + 1]
            currentView.nextKeyView = nextView
            
        }
    }
}
