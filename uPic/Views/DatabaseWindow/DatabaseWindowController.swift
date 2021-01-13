//
//  DatabaseWindowController.swift
//  uPic
//
//  Created by Licardo on 2021/1/13.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa

class DatabaseWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        if #available(OSX 11.0, *) {
            window?.subtitle = "\(DBManager.shared.getHistoryList().count) " + "items".localized
        } else {
            window?.title += "  \(DBManager.shared.getHistoryList().count) " + "items".localized
        }
    }
}

extension DatabaseWindowController: NSWindowDelegate {
    
    func windowWillBeginSheet(_ notification: Notification) {
    }
    
    func windowWillClose(_ notification: Notification) {
        // 关闭偏好设置时在去掉 Dock 栏显示应用图标
        NSApp.setActivationPolicy(.accessory)
    }
}
