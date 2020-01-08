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
    var statusItem: NSStatusItem? = nil
    let indicator = NSProgressIndicator()
    
    @IBOutlet weak var statusItemMenu: NSMenu!
    
    // 是否正在上传
    var uploding = false
    // 需要上传的文件
    var needUploadFiles = [Any]()
    // 上传成功的url
    var resultUrls = [String]()
    
    // MARK: - Cli Support
    // 上传来源
    var uploadSourceType: UploadSourceType! = .normal
    
    lazy var preferencesWindowController: PreferencesWindowController = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? PreferencesWindowController ?? PreferencesWindowController()
    }()
    
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let isCommandLineState = Cli.shared.handleCommandLine()
        if isCommandLineState {
            return
        }
        
        // Register events and status bar menus only in non-command line mode
        
        // Set status bar icon and progress icon
        setupStatusBar()
        
        // Request notification permission
        NotificationExt.requestAuthorization()
        
        bindShortcuts()
        
        // Add Finder context menu file upload listener
        UploadNotifier.addObserver(observer: self, selector: #selector(uploadFilesFromFinderMenu), notification: .uploadFiles)
        
        // Add URL scheme listening
        NSAppleEventManager.shared().setEventHandler(self, andSelector:#selector(handleGetURLEvent(event:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        ConfigManager.shared.firstSetup()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        // Remove Finder context menu file upload listener
        UploadNotifier.removeObserver(observer: self, notification: .uploadFiles)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
    
    // Finder context menu file upload listener
    @objc func uploadFilesFromFinderMenu(notification: Notification) {
        
        let pathStr = notification.object as? String ?? ""
        uploadFilesFromPaths(pathStr)
    }
    
    @objc func handleGetURLEvent(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue{
            URLSchemeExt.shared.handleURL(urlString)
        }
    }
}
// MARK: - Statusbar
extension AppDelegate {
    
    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        setStatusBarIcon()
        setupStatusBarIndicator()
        
        registerStatusBarEvents()
    }
    
    private func setupStatusBarIndicator() {
        guard let statusItem = statusItem else {
            return
        }
        if let button = statusItem.button {
            indicator.frame = NSRect(x: (button.frame.width - 16) / 2,
                                     y: (button.frame.height - 16) / 2,
                                     width: 16,
                                     height: 16)
            button.addSubview(indicator)
        }
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
    
    private func registerStatusBarEvents() {
        guard let statusItem = statusItem else {
            return
        }
        statusItem.menu = nil
        
        if let button = statusItem.button {
            
            button.window?.delegate = self
            
            button.window?.registerForDraggedTypes([NSPasteboard.PasteboardType("NSFilenamesPboardType")])
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
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        guard let statusItem = statusItem else {
            return
        }
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
        guard let statusItem = statusItem else {
            return
        }
        
        if isIndicator {
            DispatchQueue.main.async {
                statusItem.button?.image = nil
                self.indicator.doubleValue = 0.0
                self.indicator.isHidden = false
            }
            
        } else {
            let icon = NSImage(named: "statusIcon")
            icon!.isTemplate = true
            DispatchQueue.main.async {
                statusItem.button?.image = icon
                self.indicator.isHidden = true
            }
        }
        
    }
    
    func setUpdateProcess(percent: Double) {
        self.indicator.doubleValue = percent
    }
    
    
}

// MARK: - Upload file
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
    
    /// Upload multiple file paths separated by  \n
    func uploadFilesFromPaths(_ pathStr: String) {
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
    
    // 上传多个文件
    // MARK: - Cli Support
    func uploadFiles(_ files: [Any], _ uploadSourceType: UploadSourceType? = .normal) {
        self.uploadSourceType = uploadSourceType
        
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
            uploadDone()
        } else {
            // next file
            let firstFile = self.needUploadFiles.first
            self.needUploadFiles.removeFirst()
            if firstFile is URL {
                BaseUploader.upload(url: firstFile as! URL)
            } else if firstFile is Data {
                BaseUploader.upload(data: firstFile as! Data)
            } else {
                // MARK: - Cli Support
                if self.uploadSourceType == UploadSourceType.cli {
                    Cli.shared.uploadError()
                }
                tickFileToUpload()
            }
        }
    }
    
    ///
    /// 上传成功时被调用
    ///
    func uploadCompleted(url: String) {
        self.setStatusBarIcon(isIndicator: false)
        self.resultUrls.append(url)
        
        // MARK: - Cli Support
        if self.uploadSourceType == UploadSourceType.cli {
            Cli.shared.uploadProgress(url)
        }
        
        self.tickFileToUpload()
    }
    
    ///
    /// 上传失败时被调用
    ///
    func uploadFaild(errorMsg: String? = "") {
        self.setStatusBarIcon(isIndicator: false)
        // MARK: - Cli Support
        if self.uploadSourceType == UploadSourceType.cli {
            Cli.shared.uploadError(errorMsg)
        } else {
            NotificationExt.shared.postUploadErrorNotice(errorMsg)
        }
        
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
    
    func uploadDone() {
        self.uploding = false
        // MARK: - Cli Support
        if uploadSourceType == UploadSourceType.cli {
            Cli.shared.uploadDone()
        } else {
            if self.resultUrls.count > 0 {
                let outputStr = self.copyUrls(urls: self.resultUrls)
                NotificationExt.shared.postUploadSuccessfulNotice(outputStr)
            }
        }
        
        self.resultUrls.removeAll()
    }
    
    func copyUrls(urls: [String]) -> String {
        let outputUrls = BaseUploaderUtil.formatOutputUrls(urls)
        let outputStr = outputUrls.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(outputStr, forType: .string)
        
        return outputStr
    }
}

// MARK: - Drag and drop file upload
extension AppDelegate: NSWindowDelegate, NSDraggingDestination {
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.isValid {
            if let statusItem = statusItem, let button = statusItem.button {
                button.image = NSImage(named: "uploadIcon")
            }
            return .copy
        }
        return .generic
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if sender.isValid {
            self.setStatusBarIcon(isIndicator: false)
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
        self.setStatusBarIcon(isIndicator: false)
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

// MARK: - Global shortcut
extension AppDelegate {
    
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
    
    func unbindShortcuts() {
        MASShortcutBinder.shared()?.breakBinding(withDefaultsKey: Constants.Key.selectFileShortcut)
        MASShortcutBinder.shared()?.breakBinding(withDefaultsKey: Constants.Key.pasteboardShortcut)
        MASShortcutBinder.shared()?.breakBinding(withDefaultsKey: Constants.Key.screenshotShortcut)
    }
}
