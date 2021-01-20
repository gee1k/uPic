//
//  WindowManager.swift
//  uPic
//
//  Created by Licardo on 2021/1/20.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa

class WindowManager {
    static let shared = WindowManager()
    init() {
        print("Class 'WindowManager' is initialized")
    }
}

extension WindowManager {
    func instantiateControllerFromStoryboard<Controller>(storyboard name: String, withIdentifier identifier: String) -> Controller {
        let storyboard = NSStoryboard(name: name, bundle: nil)
        guard let controller = storyboard.instantiateController(withIdentifier: identifier) as? Controller else {
            fatalError("Can't find Controller: \(identifier)")
        }
        return controller
    }

    // 显示对应 Identifier 的窗口
    func showWindow(storyboard name: String, withIdentifier identifier: String, withTitle title: String? = nil) {
        let windowController = instantiateControllerFromStoryboard(storyboard: name, withIdentifier: identifier) as NSWindowController
        if let windowTitle = title {
            windowController.window?.title = windowTitle
        }

        windowController.showWindow(self)
        windowController.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }
}
