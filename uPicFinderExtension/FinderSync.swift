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
    
    // MARK: - Menu and toolbar item support
    
    override var toolbarItemName: String {
        return "uPic"
    }
    
    override var toolbarItemToolTip: String {
        return "Upload selected files via uPic".localized
    }
    
    override var toolbarItemImage: NSImage {
        var image: NSImage? = nil
        switch FinderUtil.getIcon() {
        case 2:
            image = NSImage(named: "color")
        default:
            if #available(macOS 11, *) {
                image = NSImage(named: "single_new")
            } else {
                image = NSImage(named: "single")
            }
        }
        
        image?.isTemplate = true
        return image!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        // Produce a menu for the extension.
        
        switch menuKind {
        case .contextualMenuForItems, .toolbarItemMenu:
            let menu = NSMenu(title: "")
            let uploadMenuItem = NSMenuItem(title: "Upload via uPic".localized, action: #selector(uploadFile(_:)), keyEquivalent: "")
            
            switch FinderUtil.getIcon() {
            case 0:
                uploadMenuItem.image = nil
            case 2:
                uploadMenuItem.image = NSImage(named: "color")
            default:
                if #available(macOS 11, *) {
                    uploadMenuItem.image = NSImage(named: "single_new")
                } else {
                    uploadMenuItem.image = NSImage(named: "single")
                }
            }
            
            uploadMenuItem.image?.isTemplate = true
            menu.addItem(uploadMenuItem)
            
            return menu
        default:
            break
        }
        
        return nil
    }
    
    @IBAction func uploadFile(_ sender: AnyObject?) {
        if let items = FIFinderSyncController.default().selectedItemURLs() {
            var paths = ""
            for item in items {
                let filePath = item.path
                paths = "\(paths)\(filePath)\n"
            }
            let encodeUrl = "uPic://files?\(paths)".urlEncoded()
            
            if let url = URL(string: encodeUrl) {
                NSWorkspace.shared.open(url)
            } else {
                UploadNotifier.postNotification(.uploadFiles, object: paths)
            }
        }
    }
}
