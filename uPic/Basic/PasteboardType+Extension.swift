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
    
    static let backwardsCompatibleURL: NSPasteboard.PasteboardType = {
        
        if #available(OSX 10.13, *) {
            return NSPasteboard.PasteboardType.URL
        } else {
            return NSPasteboard.PasteboardType(kUTTypeURL as String)
        }
        
    } ()
    
    static let gif: NSPasteboard.PasteboardType = kUTType(kUTTypeGIF)
    
    static let jpeg: NSPasteboard.PasteboardType = kUTType(kUTTypeJPEG)
    
    static let bmp: NSPasteboard.PasteboardType = kUTType(kUTTypeBMP)
    
    static let ico: NSPasteboard.PasteboardType = kUTType(kUTTypeICO)
    
    static func kUTType(_ cf: CFString) -> NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(cf as String)
    }
    
}
