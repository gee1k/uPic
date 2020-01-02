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

    let previewTypes = ["jpeg", "jpg", "png", "gif", "bmp", "tiff"]

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var uploadFromSelectFileMenuItem: NSMenuItem!
    
    @IBOutlet weak var uploadFromPasteboardMenuItem: NSMenuItem!
    @IBOutlet weak var uploadFromScreenshotMenuItem: NSMenuItem!
    @IBOutlet weak var historyMenu: NSMenu!
    @IBOutlet weak var cancelUploadMenuItem: NSMenuItem!
    @IBOutlet weak var cancelUploadMenuSeparator: NSMenuItem!
    @IBOutlet weak var hostMenuItem: NSMenuItem!
    @IBOutlet weak var ouputFormatMenuItem: NSMenuItem!
    @IBOutlet weak var compressFactorMenuItem: NSMenuItem!

    override func awakeFromNib() {

        statusMenu.delegate = self
        
        resetHostMenu()
        resetUploadHistory()
        refreshOutputFormat()
        resetCompressFactor()
        addObserver()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        // Set shortcut key for upload menu
        setupItemShortcut(uploadFromSelectFileMenuItem, Constants.Key.selectFileShortcut)
        setupItemShortcut(uploadFromPasteboardMenuItem, Constants.Key.pasteboardShortcut)
        setupItemShortcut(uploadFromScreenshotMenuItem, Constants.Key.screenshotShortcut)
        
        (NSApplication.shared.delegate as? AppDelegate)?.unbindShortcuts()
        
        refreshOutputFormat()
        resetCompressFactor()
        
        // 正在上传
        if (NSApplication.shared.delegate as? AppDelegate)?.uploding ?? false {
            self.cancelUploadMenuItem.isHidden = false
            self.cancelUploadMenuSeparator.isHidden = false
        } else {
            self.cancelUploadMenuItem.isHidden = true
            self.cancelUploadMenuSeparator.isHidden = true
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        (NSApplication.shared.delegate as? AppDelegate)?.bindShortcuts()
    }
    
    // cancel upload
    @IBAction func cancelUploadMenuItemClicked(_ sender: Any) {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadCancel()
        self.cancelUploadMenuItem.isHidden = true
        self.cancelUploadMenuSeparator.isHidden = true
    }
    
    // select files
    @IBAction func selectFileMenuItemClicked(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.selectFile()
    }

    // upload pasteboard files
    @IBAction func uploadPasteboardMenuItemClicked(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadByPasteboard()
    }

    // upload bu screenshot
    @IBAction func screenshotMenuItemClicked(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.screenshotAndUpload()
    }

    // open preference window
    @IBAction func preferenceMenuItemClicked(_ sender: NSMenuItem) {
        let preferencesWindowController = (NSApplication.shared.delegate as? AppDelegate)?.preferencesWindowController
        preferencesWindowController?.showWindow(sender)

        // 将应用界面浮到最上层
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindowController?.window?.makeKeyAndOrderFront(preferencesWindowController)
    }

    // open tutorials
    @IBAction func guideMenuItemClicked(_ sender: NSMenuItem) {
        guard let url = URL(string: "https://blog.svend.cc/upic/") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    // import hosts from config file
    @IBAction func importHostsMenuItemClicked(_ sender: NSMenuItem) {
        ConfigManager.shared.importHosts()
    }
    
    // export hosts to config file
    @IBAction func exportHostsMenuItemClicked(_ sender: NSMenuItem) {
        ConfigManager.shared.exportHosts()
    }
    
    
    // support -- paypal
    @IBAction func paypalMenuItemClicked(_ sender: Any) {
        (NSApplication.shared.delegate as? AppDelegate)?.sponsorByPaypal()
    }

    // support -- alipay
    @IBAction func alipayMenuItemClicked(_ sender: Any) {
        (NSApplication.shared.delegate as? AppDelegate)?.sponsorByAlipay()
    }

    // support -- wechat pay
    @IBAction func wechatPayMenuItemClicked(_ sender: Any) {
        (NSApplication.shared.delegate as? AppDelegate)?.sponsorByWechatPay()
    }

    // quit app
    @IBAction func quitMenuItemClicked(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }

    // change output format
    @IBAction func ouputFormatMenuItemClicked(_ sender: NSMenuItem) {
        ConfigManager.shared.setOutputType(sender.tag)
        self.refreshOutputFormat()
    }

    // change current host
    @objc func changeDefaultHost(_ sender: NSMenuItem) {
        self.setDefaultHost(id: sender.tag)
    }

    // change compress factor
    @objc func changeCompressFactor(_ sender: NSMenuItem) {
        ConfigManager.shared.compressFactor = sender.tag
        self.refreshCompressFactor()
    }

    // reset host menu list
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
        }
        hostMenuItem.submenu?.delegate = self
        self.refreshDefaultHost()
    }

    // reset compress factor menu list
    @objc func resetCompressFactor() {
        compressFactorMenuItem.submenu?.removeAllItems()
        let maxFactor = 100
        let factorStep = 10
        for factor in stride(from: 10, through: maxFactor, by: factorStep) {
            var title = "\(factor)%"
            if factor >= 100 {
                title = "Off".localized
            }
            let menuItem = NSMenuItem(title: title, action: #selector(changeCompressFactor(_:)), keyEquivalent: "")
            menuItem.tag = factor
            menuItem.isEnabled = true
            menuItem.target = self
            compressFactorMenuItem.submenu?.addItem(menuItem)
        }

        compressFactorMenuItem.submenu?.delegate = self
        self.refreshCompressFactor()
    }

    // reset history record menu list
    @objc func resetUploadHistory() {

        historyMenu.cancelTracking()
        historyMenu.removeAllItems()
        
        let imgMenuItem = NSMenuItem()
        historyMenu.addItem(imgMenuItem)
        
        let historyList = ConfigManager.shared.getHistoryList()
        let previewView = HistoryThumbnailView()
        previewView.historyList = historyList
        historyMenu.delegate = previewView
        previewView.superMenu = historyMenu
        previewView.frame.size = NSSize(width: HistoryRecordWidthGlobal, height: 400)
        imgMenuItem.view = previewView
    }

    // copy history url
    @objc func copyUrl(_ sender: NSMenuItem) {
        var url = sender.title
        if (url.isEmpty) {
            url = sender.toolTip ?? url
        }
        let outputUrl = (NSApplication.shared.delegate as? AppDelegate)?.copyUrls(urls: [url])
        NotificationExt.shared.postCopySuccessfulNotice(outputUrl)
    }
    
    // refresh current host to select
    func refreshDefaultHost() {
        let defaultHostId = Defaults[.defaultHostId]

        var hasDefault = false
        let items = hostMenuItem.submenu!.items
        for item in items {
            if item.tag == defaultHostId {
                item.state = .on
                hasDefault = true
            } else {
                item.state = .off
            }
        }

        if (!hasDefault && items.first != nil) {
            self.setDefaultHost(id: items.first!.tag)
        }

        if let host = ConfigManager.shared.getDefaultHost() {
            self.setHostMenuTitle(hostName: host.name)
        }
    }

    // refresh output format to select
    func refreshOutputFormat() {
        let outputType = ConfigManager.shared.getOutputType()
        for item in ouputFormatMenuItem.submenu!.items {
            if item.tag == outputType.rawValue {
                item.state = .on
            } else {
                item.state = .off
            }
        }
        
        let title = outputType.title
        
        self.setOutputFormatMenuTitle(factorTitle: title)
    }
    
    func setOutputFormatMenuTitle(factorTitle: String?) {
        let outputFormatTitle = "Output format".localized

        if let subTitle = factorTitle {

            let str = "\(outputFormatTitle)   \(subTitle)"
            let attributed = NSMutableAttributedString(string: str)
            let subTitleAttr = [NSAttributedString.Key.font: NSFont.menuFont(ofSize: 12), NSAttributedString.Key.foregroundColor: NSColor.gray]
            attributed.setAttributes(subTitleAttr, range: NSRange(outputFormatTitle.utf16.count + 1 ..< str.utf16.count))
            ouputFormatMenuItem.attributedTitle = attributed
        } else {
            ouputFormatMenuItem.title = outputFormatTitle
        }
    }

    // refresh compress factor to select
    func refreshCompressFactor() {
        let compressFactor = ConfigManager.shared.compressFactor
        for item in compressFactorMenuItem.submenu!.items {
            if item.tag == compressFactor {
                item.state = .on
            } else {
                item.state = .off
            }
        }

        var title = "\(compressFactor)%"
        if compressFactor >= 100 {
            title = "Off".localized
        }
        self.setCompressFactorMenuTitle(factorTitle: title)
    }

    // write current host to ConfigManager. refresh current host select
    func setDefaultHost(id: Int) {
        Defaults[.defaultHostId] = id
        self.refreshDefaultHost()
    }

    // show current host name in hosts menu title
    func setHostMenuTitle(hostName: String?) {
        let hostMenuTitle = "Host".localized

        if let subTitle = hostName {

            let str = "\(hostMenuTitle)   \(subTitle)"
            let attributed = NSMutableAttributedString(string: str)
            let subTitleAttr = [NSAttributedString.Key.font: NSFont.menuFont(ofSize: 12), NSAttributedString.Key.foregroundColor: NSColor.gray]
            attributed.setAttributes(subTitleAttr, range: NSRange(hostMenuTitle.utf16.count + 1 ..< str.utf16.count))
            hostMenuItem.attributedTitle = attributed
        } else {
            hostMenuItem.title = hostMenuTitle
        }

    }

    // show factor name in compress factor menu title
    func setCompressFactorMenuTitle(factorTitle: String?) {
        let compressFactorMenuTitle = "Compress images before uploading".localized

        if let subTitle = factorTitle {
            let str = "\(compressFactorMenuTitle)   \(subTitle)"
            let attributed = NSMutableAttributedString(string: str)
            let subTitleAttr = [NSAttributedString.Key.font: NSFont.menuFont(ofSize: 12), NSAttributedString.Key.foregroundColor: NSColor.gray]
            attributed.setAttributes(subTitleAttr, range: NSRange(compressFactorMenuTitle.utf16.count + 1 ..< str.utf16.count))
            compressFactorMenuItem.attributedTitle = attributed
        } else {
            compressFactorMenuItem.title = compressFactorMenuTitle
        }

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

// MARK: - Shortcut key configuration
extension StatusMenuController {
    
    
    /// Read the global shortcut key configuration in the mashshortcut to the menu bar option
    /// - Parameters:
    ///   - item: Menu item
    ///   - key: MASShortcut key
    func setupItemShortcut(_ item: NSMenuItem, _ key: String) {
        
        guard let data = Defaults.data(forKey: key), let shortcut = NSKeyedUnarchiver.unarchiveObject(with: data) as? MASShortcut else {
            item.keyEquivalent = ""
            item.keyEquivalentModifierMask = []
            return
        }
        
        item.keyEquivalent = shortcut.keyCodeStringForKeyEquivalent
        item.keyEquivalentModifierMask = shortcut.modifierFlags
    }
}
