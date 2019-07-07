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

    var draggedFileURLs: [NSURL] {
        var urls = [NSURL]()
        if let filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] {
            for path in filenames {
                urls.append(NSURL(fileURLWithPath: path))
            }
        }
        
        if fileExtensions.count == 0 {
            return urls
        } else {
            // 过滤不支持的文件
            urls = urls.filter({url -> Bool in
                guard let fileExtension = url.pathExtension?.lowercased() else {
                    return false
                }
                
                return fileExtensions.contains(fileExtension)
            })
        }
        
        return urls
    }

    var isValid: Bool {
        return self.draggedFileURLs.count > 0
    }
}
