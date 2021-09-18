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
    var draggedFileUrls: [URL] {
        var urls: [URL] = []
        guard let filenames = draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] else {
            return urls
        }
        
        for path in filenames {
            urls.append(URL(fileURLWithPath: path))
        }
        
        if fileExtensions.count == 0 {
            return urls
        }
        
        // 过滤不支持的文件
        urls = urls.filter({url -> Bool in
            if FileManager.directoryIsExists(path: url.path) {
                return true
            }
            let fileExtension = url.pathExtension.lowercased()
            return fileExtensions.contains(fileExtension)
        })
        
        return urls
    }
    
    var draggedFromBrowserUrl: URL? {
        guard let objects = draggingPasteboard.readObjects(forClasses: [NSURL.self]), objects.count > 0 else {
            return nil
        }
        
        guard let url = objects[0] as? URL else {
            return nil
        }
        
        if fileExtensions.count == 0 {
            return url
        }
        
        let fileExtension = url.pathExtension.lowercased()
        if fileExtensions.contains(fileExtension) {
            return url
        }
        
        return nil
    }
    
    var draggedFromBrowserData: Data? {
        var retData: Data? = nil
        if let png = draggingPasteboard.data(forType: .png) {
            retData = png
        } else if let gif = draggingPasteboard.data(forType: .gif){
            retData = gif
        } else if let jpeg = draggingPasteboard.data(forType: .jpeg){
            retData = jpeg
        } else if let bmp = draggingPasteboard.data(forType: .bmp){
            retData = bmp
        } else if let ico = draggingPasteboard.data(forType: .ico){
            retData = ico
        } else if let pdf = draggingPasteboard.data(forType: .pdf){
           retData = pdf
        } else if let tiff = draggingPasteboard.data(forType: .tiff) {
            retData = tiff
        }
        
        guard let data = retData else {
            return nil
        }
        
        if fileExtensions.count == 0 {
            return data
        }
        
        
        if let ext = Swime.mimeType(data: data)?.ext, fileExtensions.contains(ext) {
            return data
        }
        
        return nil
    }
}
