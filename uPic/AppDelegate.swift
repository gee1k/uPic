//
//  AppDelegate.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/7.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /* 状态栏菜单 */
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("statusIcon"))
            button.window?.delegate = self
            button.window?.registerForDraggedTypes([NSPasteboard.PasteboardType("NSFilenamesPboardType")])
        }
        constructStatusMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

extension AppDelegate {
    
    // MARK: 状态栏菜单
    
    /* 构建状态栏菜单 */
    func constructStatusMenu() {
        let menu = NSMenu()
        let menuItem = NSMenuItem(title: NSLocalizedString("status-menu.select", comment: "选择文件"), action: #selector(AppDelegate.selectFile(_:)), keyEquivalent: "u")
        menuItem.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        menu.addItem(menuItem)
        
        menu.addItem(withTitle: NSLocalizedString("status-menu.pasteboard", comment: "上传剪切板中的图片"), action: #selector(uploadByPasteboard), keyEquivalent: "p")
        menu.addItem(withTitle: NSLocalizedString("status-menu.screenshot", comment: "截图上传"), action: #selector(screenshotAndUpload), keyEquivalent: "c")
        
        menu.addItem(NSMenuItem(title: NSLocalizedString("status-menu.clear", comment: "清除历史上传"), action: #selector(clearHistory), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        self.createOutputFormatMenu(menu: menu)
        menu.addItem(NSMenuItem(title: NSLocalizedString("status-menu.about", comment: "关于"), action: #selector(showAboutMe), keyEquivalent: ""))
        menu.addItem(withTitle: NSLocalizedString("status-menu.check-update", comment: "检查更新"), action: #selector(checkUpdate), keyEquivalent: "u")
        menu.addItem(NSMenuItem(title: NSLocalizedString("status-menu.quit", comment: "退出"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func createOutputFormatMenu(menu:NSMenu) {
        // MARK: 创建输出方式子菜单
        
        let outputFormatItem = NSMenuItem(title: NSLocalizedString("status-menu.output", comment: "Markdown 格式"), action: nil, keyEquivalent: "")
        let outputFormatItemSubmenu = NSMenu()
        let urlFormat = NSMenuItem(title: "URL", action: #selector(AppDelegate.changeOutputFormat(_:)), keyEquivalent: "")
        urlFormat.tag = 0
        let imageFormat = NSMenuItem(title: "Image", action: #selector(AppDelegate.changeOutputFormat(_:)), keyEquivalent: "")
        imageFormat.tag = 1
        let markdownFormat = NSMenuItem(title: "Markdown", action: #selector(AppDelegate.changeOutputFormat(_:)), keyEquivalent: "")
        markdownFormat.tag = 2
        outputFormatItemSubmenu.addItem(urlFormat)
        outputFormatItemSubmenu.addItem(imageFormat)
        outputFormatItemSubmenu.addItem(markdownFormat)
        
        // 获取数据中保存的输出格式，默认选中对应的格式菜单
        let outputFormat = self.getOutputFormat()
        for item in outputFormatItemSubmenu.items {
            if item.tag == outputFormat {
                item.state = NSControl.StateValue.on
            }
        }
        
        outputFormatItem.submenu = outputFormatItemSubmenu
        menu.addItem(outputFormatItem)
    }
    
    /* 选择文件 */
    @objc func selectFile(_ sender: Any?) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = SmmsPic.imageTypes
        openPanel.begin { (result) -> Void in
            openPanel.close()
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                let selectedPath = openPanel.url!.path
                let url: URL = URL(fileURLWithPath: selectedPath)
                
                SmmsPic.share.upload(url, callback: self.uploadCallBack)
            }
        }
    }
    
    @objc func uploadByPasteboard() {
        let pasteboardType = NSPasteboard.general.types?.first
        
        if (pasteboardType == NSPasteboard.PasteboardType.png) {
            let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.png)
            SmmsPic.share.upload(imgData!, callback: self.uploadCallBack)
        } else if (pasteboardType == NSPasteboard.PasteboardType.fileURL) {
            
            let filePath = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.fileURL)!
            let url = URL(string: filePath)!
            
            if (!SmmsPic.imageTypes.contains(url.pathExtension)) {
                NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.error.title", comment: "上传失败"), subTitle: "", body: NSLocalizedString("copied-file-format-is-not-supported", comment: "复制的文件格式不支持"))
                return
            }
            
            let fileManager = FileManager.default
            if (!url.isFileURL || !fileManager.fileExists(atPath: url.path)) {
                debugPrint("复制的文件不存在或已被删除！")
                NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.error.title", comment: "上传失败"), subTitle: "", body: NSLocalizedString("copied-file-does-not-exist", comment: "复制的文件不存在或已被删除"))
                return
            }
            SmmsPic.share.upload(url, callback: self.uploadCallBack)
        } else {
            NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.error.title", comment: "上传失败"), subTitle: "", body: NSLocalizedString("copied-file-format-is-not-supported", comment: "复制的文件格式不支持"))
        }
    }
    
    @objc func screenshotAndUpload() {
        
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-c"]
        task.launch()
        task.waitUntilExit()
        
        self.uploadByPasteboard()
    }
    
    @objc func changeOutputFormat(_ sender: NSMenuItem!) {
        let items:[NSMenuItem] = sender.menu!.items
        for item in items {
            if item.tag == sender.tag {
                item.state = .on
            } else {
                item.state = .off
            }
        }
        
        self.setOutputFomart(format: sender.tag)
    }
    
    @objc func clearHistory() {
        SmmsPic.share.clearHistory(callback: {(data:JSON) -> Void in
            let code = data["code"]
            let msg = data["msg"].stringValue
            let title = "error" == code ? NSLocalizedString("clear.notification.error.title", comment: "清除历史上传失败通知标题") : NSLocalizedString("clear.notification.success.title", comment: "清除历史上传失败通知标题")
            NotificationExt.share.sendNotification(title: title, subTitle: "", body: msg)
        })
    }
    
    
    @objc func showAboutMe() {
        alertInfo(withText: NSLocalizedString("about-window.title", comment: "关于窗口的标题：关于"), withMessage: "\(getAppInfo()) \(NSLocalizedString("about-window.message", comment: "关于窗口的消息：上传图片到 https://sm.ms")) \n\nAuthor: Svend Jin \nWebsite: https://svend.cc \nGithub: https://github.com/gee1k/uPic \n", oKButtonTitle: "Github", cancelButtonTitle: NSLocalizedString("alert-info-button.titile", comment: "提示窗口确定按钮的标题：确定"), okHandler: openGithub)
    }
    
    @objc func checkUpdate() {
        UPicUpdater.share.check(){}
    }
    
    
    @objc func openGithub() {
        if let url = URL(string: "https://github.com/gee1k/uPic"), NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }
    
    func uploadCallBack(data: JSON) {
        let code = data["code"]
        if "error" == code {
            let msg = data["msg"].stringValue
            debugPrint(msg)
            NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.error.title", comment: "上传失败通知标题"), subTitle: "", body: msg)
        } else {
            let data = data["data"]
            self.onUploadSuccess(data: data)
        }
    }
    
    func onUploadSuccess(data: JSON) {
//        let dataDic = data.dictionaryObject!
//        self.insertHistoryItem(item: dataDic)
        
        var url = data["url"].stringValue
        
        let outputFormat = self.getOutputFormat()
        switch outputFormat {
        case 1:
            url = "<img src='\(url)'/>"
            break
        case 2:
            url = "![pic](\(url))"
            break
        case .none: break
            
        case .some(_): break
            
        }
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(url, forType: .string)
        
        NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.success.title", comment: "上传成功通知标题"), subTitle: NSLocalizedString("upload.notification.success.subtitle", comment: "上传成功通知副标题"), body: url)
    }
    
}

extension AppDelegate: NSWindowDelegate, NSDraggingDestination {
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.isImageFile {
            if let button = statusItem.button {
                button.image = NSImage(named: "uploadIcon")
            }
            return .copy
        }
        return .generic
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let uploadCallBack = self.uploadCallBack
        if sender.isImageFile {
            let imgurl = sender.draggedFileURL!.absoluteURL
            let imgData = NSData(contentsOf: imgurl!)
            SmmsPic.share.upload(imgData! as Data, callback: uploadCallBack)
            return true
        }
        return false
    }
    
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    func draggingExited(_ sender: NSDraggingInfo?) {
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
        }
    }
    
    func draggingEnded(_ sender: NSDraggingInfo) {
        if let button = statusItem.button {
            button.image = NSImage(named: "statusIcon")
        }
    }
}


extension AppDelegate {
    
    // MARK: 本地文件操作扩展
    
    func getHistoryList() -> Array<Any> {
        return UserDefaults.standard.array(forKey: "history") ?? Array()
    }
    
    func insertHistoryItem(item: Any) -> Void {
        var array:Array = self.getHistoryList()
        array.append(item)
        self.setHistoryList(array: array)
    }
    
    func setHistoryList(array: Array<Any>) -> Void {
        UserDefaults.standard.setValue(array, forKeyPath: "history")
    }
    
    func setOutputFomart(format:Int) -> Void {
        UserDefaults.standard.set(format, forKey: "output-format")
    }
    
    func getOutputFormat() -> Int? {
        return UserDefaults.standard.integer(forKey: "output-format")
    }
}
