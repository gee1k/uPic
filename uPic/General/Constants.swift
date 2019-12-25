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
    
    struct CachePath {
        static let historyTableName: String = "historyTable"
        static var databasePath: String {
            let cachePaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,
                                                                 FileManager.SearchPathDomainMask.userDomainMask, true)
            
            let bundleIdentifier = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
            return "\(cachePaths[0])/\(bundleIdentifier)/uPic.db"
        }
    }

    struct Key {
        static let selectFileShortcut = "uPic_SelectFileShortcut"
        static let pasteboardShortcut = "uPic_PasteboardShortcut"
        static let screenshotShortcut = "uPic_ScreenshotShortcut"
    }
}

