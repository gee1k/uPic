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
        return "Upload selected files via uPic"
    }

    override var toolbarItemImage: NSImage {
        return NSImage(named: "icon")!
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        // Produce a menu for the extension.

        switch menuKind {
        case .contextualMenuForItems, .toolbarItemMenu:
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
                
                // 否则说明选中项中包含文件，则创建上传菜单
                let menu = NSMenu(title: "")
                let uploadMenuItem = NSMenuItem(title: NSLocalizedString("Upload via uPic", comment: "Upload via uPic"), action: #selector(uploadFile(_:)), keyEquivalent: "")
                uploadMenuItem.image = NSImage(named: "upload")
                menu.addItem(uploadMenuItem)

                // 当文件数量为0，也就说明选择的都是文件夹，则不创建菜单
                if fileNumber == 0 {
                    if menuKind == .contextualMenuForItems {
                        return nil
                    } else if menuKind == .toolbarItemMenu {
                        uploadMenuItem.isEnabled = false
                    }
                }

                return menu
            }

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

                // 从选中项中过滤掉文件夹项
                var isDirectory: ObjCBool = false
                let fileExists = FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
                if fileExists && isDirectory.boolValue {
                    continue
                }
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

