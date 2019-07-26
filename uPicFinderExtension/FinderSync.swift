//
//  FinderSync.swift
//  uPicFinderExtension
//
//  Created by Svend Jin on 2019/7/25.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {

    
    override init() {
        super.init()
        // Set up the directory we are syncing.
        let finderSync = FIFinderSyncController.default()
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: [.skipHiddenVolumes]) {
            finderSync.directoryURLs = Set<URL>(mountedVolumes)
        }
        // Monitor volumes
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(forName: NSWorkspace.didMountNotification, object: nil, queue: .main) { notification in
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                finderSync.directoryURLs.insert(volumeURL)
            }
        }
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        // Produce a menu for the extension.
        
        // 当前右键类型不是在 Finder 中的文件或者文件夹时不创建菜单
        if menuKind != .contextualMenuForItems {
            return nil
        }
        
        // 获取当前选中的文件、文件夹
        if let items = FIFinderSyncController.default().selectedItemURLs() {
            // 统计选中项中，文件的数量
            var fileNumber = 0
            
            for item in items {
                var isDirectory: ObjCBool = false
                let fileExists = FileManager.default.fileExists(atPath: item.path, isDirectory: &isDirectory)
                if fileExists && isDirectory.boolValue {
                    continue
                }
                
                fileNumber = fileNumber + 1
            }
            
            // 当文件数量为0，也就说明选择的都是文件夹，则不创建菜单
            if fileNumber == 0 {
                return nil
            }
            
            // 否则说明选中项中包含文件，则创建上传菜单
            let menu = NSMenu(title: "")
            let uploadMenuItem = NSMenuItem(title: NSLocalizedString("upload-by-uPic", comment: "使用uPic上传"), action: #selector(uploadFile(_:)), keyEquivalent: "")
            uploadMenuItem.image = NSImage(named: "upload")
            menu.addItem(uploadMenuItem)
            return menu
        }
        
        return nil
        
    }
    
    @IBAction func uploadFile(_ sender: AnyObject?) {
        if let items = FIFinderSyncController.default().selectedItemURLs() {
            var path = ""
            for item in items {
                let filePath = item.path
                
                // 从选中项中过滤掉文件夹项
                var isDirectory: ObjCBool = false
                let fileExists = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
                if fileExists && isDirectory.boolValue {
                    continue
                }
                path = "\(path)\(filePath)\n"
            }
            UploadNotifier.postNotification(.uploadFiles, object: path)
        }
        
    }

}

