//
//  NSDragingInfoExt.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/8.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

extension NSDraggingInfo {
    
    var imageFileExtensions: [String] {
        get {
            return SmmsPic.imageTypes
        }
    }
    
    var draggedFileURL: NSURL? {
        let filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String]
        let path = filenames?.first
        return path.map(NSURL.init)
    }
    
    var isImageFile: Bool {
        get {
            guard let fileExtension = draggedFileURL?.pathExtension?.lowercased() else {
                return false
            }
            return imageFileExtensions.contains(fileExtension)
        }
    }
}
