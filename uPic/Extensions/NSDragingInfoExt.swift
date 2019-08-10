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

    // 本地文件管理器中拖拽的文件，可多个
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
    
    // 从浏览器里拖拽出来的图片，单张
    var draggedFromBrowserData: Data? {
        
        if let tiff = draggingPasteboard.data(forType: NSPasteboard.PasteboardType.tiff) {
            let jpg = tiff.convertImageData(.jpeg)
            return jpg
        } else if let pdf = draggingPasteboard.data(forType: NSPasteboard.PasteboardType.pdf) {
            return pdf
        } else if let png = draggingPasteboard.data(forType: NSPasteboard.PasteboardType.png) {
            return png
        } else if let urlStr = draggingPasteboard.string(forType: NSPasteboard.PasteboardType.string) {
            if let url = URL(string: urlStr.urlEncoded()), let data = try? Data(contentsOf: url)  {
                return data
            }
        }
        return nil
    }

    var isValid: Bool {
        return self.draggedFileURLs.count > 0 || self.draggedFromBrowserData != nil
    }
}
