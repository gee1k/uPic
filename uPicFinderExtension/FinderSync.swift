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
        switch FinderUtil.getIcon() {
        case 2:
            return NSImage(named: "color")!
        default:
            return NSImage(named: "single")!
        }
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        // Produce a menu for the extension.

        // 如果是关闭状态下，则不把 uPic 注入到系统菜单栏上
        if (FinderUtil.getFinderStatus() == 0) {
            return nil
        }
        
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
                uploadMenuItem.image = NSImage(named: "single")
            }
            
            menu.addItem(uploadMenuItem)

            return menu
        default:
            break
        }

        return nil

    }

    @IBAction func uploadFile(_ sender: AnyObject?) {
        if let items = FIFinderSyncController.default().selectedItemURLs() {
            var path = ""
            for item in items {
                let filePath = item.path
                path = "\(path)\(filePath)\n"
            }
            let encodeUrl = "uPic://files?\(path)".urlEncoded()
            
            if let url = URL(string: encodeUrl) {
                NSWorkspace.shared.open(url)
            } else {
                UploadNotifier.postNotification(.uploadFiles, object: path)
            }
            
        }
    }

}

