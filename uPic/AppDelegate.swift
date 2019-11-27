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
import AppKit
import ScriptingBridge
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /* 状态栏菜单 */
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let indicator = NSProgressIndicator()

    @IBOutlet weak var statusItemMenu: NSMenu!

    // 是否正在上传
    var uploding = false
    // 需要上传的文件
    var needUploadFiles = [Any]()
    // 上传成功的url
    var resultUrls = [String]()

    lazy var preferencesWindowController: PreferencesWindowController = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? PreferencesWindowController ?? PreferencesWindowController()
    }()
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        // 添加 url scheme 监听
        NSAppleEventManager.shared().setEventHandler(self, andSelector:#selector(handleGetURLEvent(event:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))

    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        ConfigManager.shared.firstSetup()
        
        // Request notification permission
        NotificationExt.requestAuthorization()
        
        self.resetNewVersionLaunchAtLogin()

        self.setupStatusBar()
        
        self.bindShortcuts()
        
        // 添加 Finder 右键文件上传监听
        UploadNotifier.addObserver(observer: self, selector: #selector(uploadFilesFromFinderMenu), notification: .uploadFiles)
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSStatusBar.system.removeStatusItem(statusItem)
        // 移除 Finder 右键文件上传监听
        UploadNotifier.removeObserver(observer: self, notification: .uploadFiles)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }

    func resetNewVersionLaunchAtLogin() {
        guard let launchAtLogin = ConfigManager.shared.launchAtLogin else {
            return
        }
        if launchAtLogin == ._true {
            ConfigManager.shared.launchAtLogin = BoolType._false
            ConfigManager.shared.launchAtLogin = BoolType._true
        }
    }
    
    // 在 Finder 中选中文件右键上传时调用的方法
    @objc func uploadFilesFromFinderMenu(notification: Notification) {

        let pathStr = notification.object as? String ?? ""
        let paths = pathStr.split(separator: Character("\n"))
        
        let fileExtensions = BaseUploader.getFileExtensions()
        var urls = [URL]()
        
        for path in paths {
            let sPath = String(path)
            if (fileExtensions.count == 0 || fileExtensions.contains(sPath.pathExtension.lowercased())) {
                let url = URL(fileURLWithPath: sPath)
                urls.append(url)
            }
        }
        
        if (urls.count == 0) {
            NotificationExt.shared.postUploadErrorNotice("File format not supported!".localized)
            return
        }
        
        self.uploadFiles(urls)
    }
    
    @objc func handleGetURLEvent(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue, let url = NSURL(string: urlString) {
            // 解析出参数
            var param = urlString
            let i = "\(url.scheme!)://".count
            param.removeFirst(i)
            
            var fileUrl: URL?
            if param.isAbsolutePath {
                fileUrl = URL(fileURLWithPath: param)
            } else {
                fileUrl = URL(string: param.urlDecoded())
            }
            
            if let fileUrl = fileUrl, let data = try? Data(contentsOf: fileUrl)  {
                self.uploadFiles([data])
            }
        }
    }

}

extension AppDelegate {

    func setupStatusBar() {
        if let button = statusItem.button {
            self.setStatusBarIcon()
            button.window?.delegate = self

            button.window?.registerForDraggedTypes([NSPasteboard.PasteboardType("NSFilenamesPboardType")])
            indicator.frame = NSRect(x: (button.frame.width - 16) / 2,
                                     y: (button.frame.height - 16) / 2,
                                     width: 16,
                                     height: 16)
            button.addSubview(indicator)
            button.action = #selector(statusBarButtonClicked)
            button.sendAction(on: [.leftMouseUp, .leftMouseDown,
                                   .rightMouseUp, .rightMouseDown])

            // 注册拖拽文件格式支持。使其支持浏览器拖拽的URL、tiff。以及Safari 有些情况(例如，百度搜图，在默认搜索列表。不进入详情时)下拖拽的时候获取到的是图片URL字符串
            if #available(OSX 10.13, *) {
                button.window?.registerForDraggedTypes([.URL, .fileURL, .string, .html])
            } else {
                // Fallback on earlier versions
                button.window?.registerForDraggedTypes([.png, .tiff, .pdf, .string, .html])
            }

        }

        statusItem.menu = nil
        
        // 初始化任务栏进度图标
        indicator.minValue = 0.0
        indicator.maxValue = 1.0
        indicator.doubleValue = 0.0
        indicator.isIndeterminate = false
        indicator.controlSize = NSControl.ControlSize.small
        indicator.style = NSProgressIndicator.Style.spinning
        indicator.isHidden = true
        indicator.toolTip = "Right click to cancel the current upload task".localized
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .leftMouseDown || event.type == .leftMouseUp
            || event.modifierFlags.contains(.control)
        {
            statusItem.menu = statusItemMenu
            statusItem.button?.performClick(self)
            statusItem.menu = nil
        } else if event.type == .rightMouseUp {
            if uploding {
                self.uploadCancel()
            } else {
                statusItem.menu = statusItemMenu
                statusItem.button?.performClick(self)
                statusItem.menu = nil
            }
        }
    }

    func setStatusBarIcon(isIndicator: Bool = false) {

        if isIndicator {
            DispatchQueue.main.async {
                self.statusItem.button?.image = nil
                self.indicator.doubleValue = 0.0
                self.indicator.isHidden = false
            }

        } else {
            let icon = NSImage(named: "statusIcon")
            icon!.isTemplate = true
            DispatchQueue.main.async {
                self.statusItem.button?.image = icon
                self.indicator.isHidden = true
            }
        }

    }

    func setUpdateProcess(percent: Double) {
        self.indicator.doubleValue = percent
    }


}

extension AppDelegate {

    /* 选择文件 */
    @objc func selectFile() {

        if self.uploding {
            NotificationExt.shared.postUplodingNotice()
            return
        }

        NSApp.activate(ignoringOtherApps: true)
        let fileExtensions = BaseUploader.getFileExtensions()

        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true

        if fileExtensions.count > 0 {
            openPanel.allowedFileTypes = fileExtensions
        }

        openPanel.begin { (result) -> Void in
            openPanel.close()
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                self.uploadFiles(openPanel.urls)
            }
        }
    }

    @objc func uploadByPasteboard() {
        if self.uploding {
            NotificationExt.shared.postUplodingNotice()
            return
        }

        if let filenames = NSPasteboard.general.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] {
            let fileExtensions = BaseUploader.getFileExtensions()
            var urls = [URL]()

            for path in filenames {
                if (fileExtensions.count == 0 || fileExtensions.contains(path.pathExtension.lowercased())) {
                    urls.append(URL(fileURLWithPath: path))
                }
            }
            if urls.count > 0 {
                self.uploadFiles(urls)
            } else {
                NotificationExt.shared.postUploadErrorNotice("File format not supported!".localized)
            }

        } else if (NSPasteboard.general.types?.first == NSPasteboard.PasteboardType.png) {
            let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.png)
            self.uploadFiles([imgData!])
        } else if (NSPasteboard.general.types?.first == NSPasteboard.PasteboardType.tiff) {
            let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.tiff)
            if let jpg = imgData?.convertImageData(.jpeg) {
                self.uploadFiles([jpg])
            }
        } else {
            if let urlStr = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string) {
                if let url = URL(string: urlStr.urlEncoded()), let data = try? Data(contentsOf: url)  {
                    self.uploadFiles([data])
                }
            }
        }

    }

    @objc func screenshotAndUpload() {

        if self.uploding {
            NotificationExt.shared.postUplodingNotice()
            return
        }

        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-c"]
        task.launch()
        task.waitUntilExit()

        if (NSPasteboard.general.types?.first == NSPasteboard.PasteboardType.png) {
            let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.png)
            self.uploadFiles([imgData!])
        }
    }


    @objc func checkUpdate() {
//        UPicUpdater.shared.check() {
//        }
    }

    // 上传多个文件
    func uploadFiles(_ files: [Any]) {
        self.needUploadFiles = files
        self.resultUrls.removeAll()

        if self.needUploadFiles.count == 0 {
            return
        }

        self.uploding = true
        self.tickFileToUpload()
    }

    // 开始上传文件队列中的第一个文件，如果所有文件上传完成则表示当前上传任务结束
    func tickFileToUpload() {
        if self.needUploadFiles.count == 0 {
            // done
            self.uploding = false
            if self.resultUrls.count > 0 {
                let outputStr = self.copyUrls(urls: self.resultUrls)
                NotificationExt.shared.postUploadSuccessfulNotice(outputStr)
                self.resultUrls.removeAll()
            }
        } else {
            // next file
            let firstFile = self.needUploadFiles.first
            self.needUploadFiles.removeFirst()
            if firstFile is URL {
                BaseUploader.upload(url: firstFile as! URL)
            } else if firstFile is Data {
                BaseUploader.upload(data: firstFile as! Data)
            }
        }
    }

    ///
    /// 上传成功时被调用
    ///
    func uploadCompleted(url: String) {
        self.setStatusBarIcon(isIndicator: false)
        self.resultUrls.append(url)
        self.tickFileToUpload()
    }

    ///
    /// 上传失败时被调用
    ///
    func uploadFaild(errorMsg: String? = "") {
        self.setStatusBarIcon(isIndicator: false)
        NotificationExt.shared.postUploadErrorNotice(errorMsg)
        self.tickFileToUpload()
    }

    ///
    /// 上传进度更新时调用
    ///
    func uploadProgress(percent: Double) {
        self.indicator.doubleValue = percent
    }

    func uploadStart() {
        self.setStatusBarIcon(isIndicator: true)
        self.indicator.doubleValue = 0.0
    }
    
    func uploadCancel() {
        BaseUploader.cancelUpload()
        self.needUploadFiles.removeAll()
        self.resultUrls.removeAll()
        self.uploding = false
    }

    func copyUrls(urls: [String]) -> String {
        var outputUrls = [String]()
        let outputFormat = Defaults[.ouputFormat]

        for url in urls {
            var outputUrl = ""
            switch outputFormat {
            case 1:
                outputUrl = "<img src='\(url)'/>"
                break
            case 2:
                outputUrl = "![](\(url))"
                break
            case 3:
                // UBB
                outputUrl = "[img]\(url)[/img]"
                break
            default:
                outputUrl = url

            }
            outputUrls.append(outputUrl)
        }

        let outputStr = outputUrls.joined(separator: "\n")

        NSPasteboard.general.clearContents()
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(outputStr, forType: .string)

        return outputStr
    }
}

extension AppDelegate: NSWindowDelegate, NSDraggingDestination {

    // MARK: 拖拽文件

    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.isValid {
            if let button = statusItem.button {
                button.image = NSImage(named: "uploadIcon")
            }
            return .copy
        }
        return .generic
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if sender.isValid {
            self.setStatusBarIcon()
            if sender.draggedFileURLs.count > 0 {
                var urls = [URL]()
                for url in sender.draggedFileURLs {
                    urls.append(url.absoluteURL!)
                }
                self.uploadFiles(urls)
            } else if let imageData = sender.draggedFromBrowserData {
                self.uploadFiles([imageData])
            }
            return true
        }
        return false
    }

    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }

    func draggingExited(_ sender: NSDraggingInfo?) {
        self.setStatusBarIcon()
    }

    func draggingEnded(_ sender: NSDraggingInfo) {
    }

}

extension AppDelegate {
    // sponsor 
    
    func sponsorByPaypal() {
        guard let url = URL(string: "https://paypal.me/geee1k") else { return }
        NSWorkspace.shared.open(url)
    }
    
    func sponsorByAlipay() {
        guard let url = URL(string: "https://raw.githubusercontent.com/gee1k/oss/master/qrcode/alipay.JPG") else { return }
        NSWorkspace.shared.open(url)
    }
    
    func sponsorByWechatPay() {
        guard let url = URL(string: "https://raw.githubusercontent.com/gee1k/oss/master/qrcode/wechat_pay.JPG") else { return }
        NSWorkspace.shared.open(url)
    }
}

extension AppDelegate {
    // Global shortcut
    func bindShortcuts() {
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: Constants.Key.selectFileShortcut) {
            self.selectFile()
        }
        
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: Constants.Key.pasteboardShortcut) {
            self.uploadByPasteboard()
        }
        
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: Constants.Key.screenshotShortcut) {
            self.screenshotAndUpload()
        }
    }
}
