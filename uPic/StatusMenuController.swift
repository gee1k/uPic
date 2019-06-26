//
//  StatusMenuController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import MASShortcut

class StatusMenuController: NSObject, NSMenuDelegate {

    @IBOutlet weak var statusMenu: NSMenu!

    @IBOutlet weak var selectFileMenuItem: NSMenuItem!
    @IBOutlet weak var uploadPasteboardMenuItem: NSMenuItem!
    @IBOutlet weak var screenshotMenuItem: NSMenuItem!
    @IBOutlet weak var hostMenuItem: NSMenuItem!
    @IBOutlet weak var ouputFormatMenuItem: NSMenuItem!
    @IBOutlet weak var historyMenuItem: NSMenuItem!
    @IBOutlet weak var preferenceMenuItem: NSMenuItem!
    @IBOutlet weak var helpMenuItem: NSMenuItem!
    @IBOutlet weak var checkUpdateMenuItem: NSMenuItem!
    @IBOutlet weak var guideMenuItem: NSMenuItem!
    @IBOutlet weak var quitMenuItem: NSMenuItem!

    override func awakeFromNib() {

        statusMenu.delegate = self

        selectFileMenuItem.title = NSLocalizedString("status-menu.select-file", comment: "Select file")
        uploadPasteboardMenuItem.title = NSLocalizedString("status-menu.pasteboard", comment: "Upload with pasteboard")
        screenshotMenuItem.title = NSLocalizedString("status-menu.screenshot", comment: "Upload with pasteboard")
        hostMenuItem.title = NSLocalizedString("status-menu.host", comment: "Host")
        ouputFormatMenuItem.title = NSLocalizedString("status-menu.output", comment: "Choose output format")
        historyMenuItem.title = NSLocalizedString("status-menu.upload-history", comment: "upload history")
        preferenceMenuItem.title = NSLocalizedString("status-menu.preference", comment: "Open Preference")
        checkUpdateMenuItem.title = NSLocalizedString("status-menu.check-update", comment: "Check update")
        quitMenuItem.title = NSLocalizedString("status-menu.quit", comment: "Quit")

        resetHostMenu()
        resetUploadHistory()
        refreshOutputFormat()
        addObserver()
    }


    @IBAction func selectFileMenuItemClicked(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.selectFile()
    }

    @IBAction func uploadPasteboardMenuItemClicked(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadByPasteboard()
    }

    @IBAction func screenshotMenuItemClicked(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.screenshotAndUpload()
    }

    @IBAction func preferenceMenuItemClicked(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.showPreference()
    }

    @IBAction func checkUpdateMenuItemClicked(_ sender: NSMenuItem) {
        // MARK: 已废弃，使用 Sparkle 进行升级
        (NSApplication.shared.delegate as? AppDelegate)?.checkUpdate()
    }

    @IBAction func guideMenuItemClicked(_ sender: NSMenuItem) {
        guard let url = URL(string: "https://blog.svend.cc/upic/") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @IBAction func quitMenuItemClicked(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }

    @IBAction func ouputFormatMenuItemClicked(_ sender: NSMenuItem) {
        Defaults[.ouputFormat] = sender.tag
        self.refreshOutputFormat()
    }

    @objc func changeDefaultHost(_ sender: NSMenuItem) {
        self.setDefaultHost(id: sender.tag)
    }

    @objc func resetHostMenu() {
        let hostItems = ConfigManager.shared.getHostItems()
        hostMenuItem.submenu?.removeAllItems()
        for item in hostItems {
            let menuItem = NSMenuItem(title: item.name, action: #selector(changeDefaultHost(_:)), keyEquivalent: "")
            menuItem.tag = item.id
            menuItem.image = Host.getIconByType(type: item.type)
            menuItem.isEnabled = true
            menuItem.target = self
            hostMenuItem.submenu?.addItem(menuItem)
            hostMenuItem.submenu?.delegate = self
        }
        self.refreshDefaultHost()
    }
    
    @objc func resetUploadHistory() {
        let historyList = ConfigManager.shared.getHistoryList()
        
        historyMenuItem.submenu?.removeAllItems()
        for url in historyList {
            let menuItem = NSMenuItem(title: url, action: #selector(copyUrl(_:)), keyEquivalent: "")
            menuItem.target = self
            historyMenuItem.submenu?.addItem(menuItem)
            historyMenuItem.submenu?.delegate = self
        }
        
        if ((historyMenuItem.submenu?.items.count ?? 0) > 0) {
            historyMenuItem.submenu?.addItem(NSMenuItem.separator())
            let menuItem = NSMenuItem(title: NSLocalizedString("status-menu.upload-history-clear", comment: "clear history"), action: #selector(clearHistory(_:)), keyEquivalent: "")
            menuItem.target = self
            historyMenuItem.submenu?.addItem(menuItem)
        } else {
            let menuItem = NSMenuItem(title: NSLocalizedString("status-menu.upload-history-empty", comment: "history is empty"), action: nil, keyEquivalent: "")
            menuItem.target = self
            historyMenuItem.submenu?.addItem(menuItem)
        }
    }
    
    @objc func copyUrl(_ sender: NSMenuItem) {
        let outputUrl = (NSApplication.shared.delegate as? AppDelegate)?.copyUrl(url: sender.title)
        NotificationExt.sendCopySuccessfulNotification(body: outputUrl)
    }
    
    @objc func clearHistory(_ sender: NSMenuItem) {
        ConfigManager.shared.clearHistoryList()
    }

    func refreshDefaultHost() {
        let outputFormat = Defaults[.defaultHostId]

        var hasDefault = false
        let items = hostMenuItem.submenu!.items
        for item in items {
            if item.tag == outputFormat {
                item.state = .on
                hasDefault = true
            } else {
                item.state = .off
            }
        }

        if (!hasDefault && items.first != nil) {
            self.setDefaultHost(id: items.first!.tag)
        }
    }

    func refreshOutputFormat() {
        let outputFormat = Defaults[.ouputFormat]
        for item in ouputFormatMenuItem.submenu!.items {
            if item.tag == outputFormat {
                item.state = .on
            } else {
                item.state = .off
            }
        }
    }

    func setDefaultHost(id: Int) {
        Defaults[.defaultHostId] = id
        self.refreshDefaultHost()
    }

    func addObserver() {
        ConfigNotifier.addObserver(observer: self, selector: #selector(resetHostMenu), notification: .changeHostItems)
        ConfigNotifier.addObserver(observer: self, selector: #selector(resetUploadHistory), notification: .changeHistoryList)
    }
    
    func removeObserver() {
        ConfigNotifier.removeObserver(observer: self, notification: .changeHostItems)
        ConfigNotifier.removeObserver(observer: self, notification: .changeHistoryList)
    }
}
