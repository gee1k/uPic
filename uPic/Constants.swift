//
//  Constants.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Foundation

struct Constants {
    
    static let none = "None"
    static let launcherAppIdentifier = "com.svend.uPicHelper"
    
    struct Key {
        static let selectFileShortcut = "uPic_SelectFileShortcut"
        static let pasteboardShortcut = "uPic_PasteboardShortcut"
        static let screenshotShortcut = "uPic_ScreenshotShortcut"
    }
    
    struct DefaultsKey {
        static let firstUsage = "uPic_FirstUsage"
        static let launchAtLogin = "uPic_LaunchAtLogin"
        
    }
}

