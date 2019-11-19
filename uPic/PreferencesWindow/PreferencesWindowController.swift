//
//  PreferencesWindowController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        // Do view setup here.
    }
    
}
extension PreferencesWindowController: NSWindowDelegate {
    
    func windowWillBeginSheet(_ notification: Notification) {
    }
    
    func windowWillClose(_ notification: Notification) {
        // 关闭偏好设置时在去掉 Dock 栏显示应用图标
        NSApp.setActivationPolicy(.accessory)
    }
}
