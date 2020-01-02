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
        guard let filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] else {
            return urls
        }
        
        for path in filenames {
            urls.append(NSURL(fileURLWithPath: path))
        }
        
        if fileExtensions.count == 0 {
            return urls
        }
        
        // 过滤不支持的文件
        urls = urls.filter({url -> Bool in
            guard let fileExtension = url.pathExtension?.lowercased() else {
                return false
            }
            
            return fileExtensions.contains(fileExtension)
        })
        
        return urls
    }
    
    // 从浏览器里拖拽出来的的文件
    var draggedFromBrowserIsValid: Bool {
        guard let objects = draggingPasteboard.readObjects(forClasses: [NSURL.self]), objects.count > 0 else {
            return false
        }
        
        guard let url = objects[0] as? URL else {
            return false
        }
        
        let ext = url.pathExtension.lowercased()
        if ext.isEmpty {
            return false
        }
        
        if fileExtensions.count > 0 && !fileExtensions.contains(ext) {
            return false
        }
        
        return true
    }
    
    var draggedFromBrowserData: Data? {
        guard let objects = draggingPasteboard.readObjects(forClasses: [NSURL.self]), objects.count > 0 else {
            return nil
        }
        
        guard let url = objects[0] as? URL else {
            return nil
        }
        
        guard let data = try? Data(contentsOf: url), let ext = Swime.mimeType(data: data)?.ext else {
            return nil
        }
        
        if fileExtensions.count > 0 && !fileExtensions.contains(ext) {
            return nil
        }
        
        return data
    }

    var isValid: Bool {
        return self.draggedFileURLs.count > 0 || self.draggedFromBrowserIsValid
    }
}
