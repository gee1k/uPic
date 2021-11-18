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
        NSLog("FinderSync() launched from %@", Bundle.main.bundlePath as NSString)
                
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
    }
    
    @IBAction func uploadFile(_ sender: AnyObject?) {
        let paths = getSelectedPathsFromFinder()
        let pathString = paths.joined(separator: "\n")
        
        let encodeUrl = "uPic://files?\(pathString)".urlEncoded()
        
        if let url = URL(string: encodeUrl) {
            NSWorkspace.shared.open(url)
        } else {
            UploadNotifier.postNotification(.uploadFiles, object: pathString)
        }
    }
    
    func getSelectedPathsFromFinder() -> [String] {
        var paths = [String]()
        if let items = FIFinderSyncController.default().selectedItemURLs(), items.count > 0 {
            items.forEach { (url) in
                paths.append(url.path)
            }
        } else if let url = FIFinderSyncController.default().targetedURL() {
            paths.append(url.path)
        }
        return paths
    }
}
