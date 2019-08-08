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

    @IBOutlet weak var selectFileMenuItem: NSMenuItem!
    @IBOutlet weak var uploadPasteboardMenuItem: NSMenuItem!
    @IBOutlet weak var screenshotMenuItem: NSMenuItem!
    @IBOutlet weak var hostMenuItem: NSMenuItem!
    @IBOutlet weak var ouputFormatMenuItem: NSMenuItem!
    @IBOutlet weak var compressFactorMenuItem: NSMenuItem!
    @IBOutlet weak var historyMenuItem: NSMenuItem!
    @IBOutlet weak var preferenceMenuItem: NSMenuItem!
    @IBOutlet weak var helpMenuItem: NSMenuItem!
    @IBOutlet weak var checkUpdateMenuItem: NSMenuItem!
    @IBOutlet weak var tutorialMenuItem: NSMenuItem!
    @IBOutlet weak var sponsorMenuItem: NSMenuItem!
    @IBOutlet weak var quitMenuItem: NSMenuItem!

    override func awakeFromNib() {

        statusMenu.delegate = self

        selectFileMenuItem.title = NSLocalizedString("status-menu.select-file", comment: "Select file")
        uploadPasteboardMenuItem.title = NSLocalizedString("status-menu.pasteboard", comment: "Upload with pasteboard")
        screenshotMenuItem.title = NSLocalizedString("status-menu.screenshot", comment: "Upload with pasteboard")
        hostMenuItem.title = NSLocalizedString("status-menu.host", comment: "Host")
        ouputFormatMenuItem.title = NSLocalizedString("status-menu.output", comment: "Choose output format")
        compressFactorMenuItem.title = NSLocalizedString("status-menu.compress-factor", comment: "Compress images before uploading")
        historyMenuItem.title = NSLocalizedString("status-menu.upload-history", comment: "upload history")
        preferenceMenuItem.title = NSLocalizedString("status-menu.preference", comment: "Open Preference")
        helpMenuItem.title = NSLocalizedString("status-menu.help", comment: "help")
        checkUpdateMenuItem.title = NSLocalizedString("status-menu.check-update", comment: "Check update")
        tutorialMenuItem.title = NSLocalizedString("status-menu.tutorial", comment: "Tutorial")
        sponsorMenuItem.title = NSLocalizedString("status-menu.sponsor", comment: "Sponsor")
        quitMenuItem.title = NSLocalizedString("status-menu.quit", comment: "Quit")

        resetHostMenu()
        resetUploadHistory()
        refreshOutputFormat()
        resetCompressFactor()
        addObserver()
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
        Defaults[.ouputFormat] = sender.tag
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
                title = "Off"
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

    // reset upload history menu list
    @objc func resetUploadHistory() {
        let historyList = ConfigManager.shared.getHistoryList()
        historyMenuItem.submenu?.removeAllItems()
        for urlStr in historyList.reversed() {
            if urlStr.isEmpty {
                continue
            }

            let menuItem = NSMenuItem(title: urlStr, action: #selector(copyUrl(_:)), keyEquivalent: "")
            menuItem.target = self

            historyMenuItem.submenu?.addItem(menuItem)
            historyMenuItem.submenu?.delegate = self

            let pathExtension = urlStr.pathExtension.lowercased()

            let canPreview = previewTypes.contains(where: { type -> Bool in
                return pathExtension.starts(with: type)
            })
            if canPreview {
                self.createPreviewImage(urlStr: urlStr)
            }
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

    // 异步请求、创建历史记录预览图
    func createPreviewImage(urlStr: String) {
        guard let url = URL(string: urlStr.urlEncoded()) else {
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                print(error.debugDescription)
            } else {
                // 根据原始url找到对应的历史记录项
                guard let originalUrlStr = response?.url?.absoluteString, let menuItem = self.historyMenuItem.submenu?.item(withTitle: originalUrlStr) else {
                    return
                }

                // 创建 NSImage 并验证其有效性，最后添加到对应的历史记录项的子菜单
                if let image = NSImage(data: data!), image.isValid {
                    let imgMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
                    imgMenuItem.image = image
                    imgMenuItem.image?.size = NSSize(width: 220, height: 230)
                    let imgSubMenu = NSMenu(title: "")
                    imgSubMenu.addItem(imgMenuItem)
                    menuItem.submenu = imgSubMenu
                }

            }
        }) as URLSessionTask

        //使用resume方法启动任务
        dataTask.resume()
    }

    // copy history url
    @objc func copyUrl(_ sender: NSMenuItem) {
        let outputUrl = (NSApplication.shared.delegate as? AppDelegate)?.copyUrl(url: sender.title)
        NotificationExt.sendCopySuccessfulNotification(body: outputUrl)
    }

    // clear all history
    @objc func clearHistory(_ sender: NSMenuItem) {
        ConfigManager.shared.clearHistoryList()
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
        let outputFormat = Defaults[.ouputFormat]
        for item in ouputFormatMenuItem.submenu!.items {
            if item.tag == outputFormat {
                item.state = .on
            } else {
                item.state = .off
            }
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
            title = "Off"
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
        let hostMenuTitle = NSLocalizedString("status-menu.host", comment: "Host")

        if let subTitle = hostName {

            let str = "\(hostMenuTitle)        \(subTitle)"
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
        let compressFactorMenuTitle = NSLocalizedString("status-menu.compress-factor", comment: "Compress images before uploading")

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
