//
//  NSDragingInfoExt.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/8.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

extension NSDraggingInfo {
    
    /* 获取当前所选的图床对应的文件类型 */
    var fileExtensions: [String] {
        get {
            return BaseUploader.getFileExtensions()
        }
    }
    
    var draggedFileURL: NSURL? {
        let filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String]
        let path = filenames?.first
        return path.map(NSURL.init)
    }
    
    var isValidFile: Bool {
        get {
            if fileExtensions.count == 0 {
                return true
            }
            
            guard let fileExtension = draggedFileURL?.pathExtension?.lowercased() else {
                return false
            }
            return fileExtensions.contains(fileExtension)
        }
    }
}
