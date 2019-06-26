//
//  PasteboardType+Extension.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/26.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa


extension NSPasteboard.PasteboardType {
    // MARK: 剪切板扩展，让 10.13 以前的版本也支持 FileUrl 类型
    
    static let backwardsCompatibleFileURL: NSPasteboard.PasteboardType = {
        
        if #available(OSX 10.13, *) {
            return NSPasteboard.PasteboardType.fileURL
        } else {
            return NSPasteboard.PasteboardType(kUTTypeFileURL as String)
        }
        
    } ()
    
}
