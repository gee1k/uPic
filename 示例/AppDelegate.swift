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
import KeyboardShortcuts
import UniformTypeIdentifiers

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /* 状态栏菜单 */
    var statusItem: NSStatusItem? = nil
    let indicator = NSProgressIndicator()
    
    @IBOutlet weak var statusItemMenu: NSMenu!
    
    // 是否正在上传
    var uploading = false
    // 需要上传的文件
    var needUploadFiles = [Any]()
    // 上传成功的url
    var resultUrls = [String]()
    var draggingData: Data?
    
    // MARK: - Cli Support
    // 上传来源
    var uploadSourceType: UploadSourceType! = .normal
    
    lazy var preferencesWindowController: PreferencesWindowController = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? PreferencesWindowController ?? PreferencesWindowController()
    }()
    
    lazy var databaseWindowController: DatabaseWindowController = {
        let storyboard = NSStoryboard(name: "Database", bundle: nil)
        return storyboard.instantiateInitialController() as? DatabaseWindowController ?? DatabaseWindowController()
    }()
    
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        Logger.shared.verbose("Application will finish launching...")
        
        if let paths = Cli.shared.getFilePaths() {
            Logger.shared.verbose("The application runs as a cli")
            Cli.shared.startUpload(paths)
            return
        }
        
        // Set status bar icon and progress icon
        setupStatusBar()
        
        // Request notification permission
        NotificationExt.requestAuthorization()
        
        Logger.shared.verbose("Listening scheme")
        // Add URL scheme listening
        NSAppleEventManager.shared().setEventHandler(self, andSelector:#selector(handleGetURLEvent(event:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Logger.shared.verbose("Application did finish launching...")

        Logger.shared.info("System Version: \(getModelIdentifier())(\(getSystemVersionString())) - App Version:\(getAppVersionString())")
        
        // Insert code here to initialize your application
        ConfigManager.shared.firstSetup()
        
        // 检查是否可以从子目录方案升级到根目录方案
        DiskPermissionManager.shared.tryUpgradeToRootDirectoryPermission()
        
        if !Defaults[.requestedAuthorization] {
            Defaults[.requestedAuthorization] = true
            Logger.shared.verbose("打开欢迎页面以及获取授权页")
            // 打开欢迎页面以及获取授权页
            _ = WindowManager.shared.showWindow(storyboard: "Welcome", withIdentifier: "welcomeWindowController")
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        Logger.shared.verbose("Application will terminate...")
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return true
    }
    
    @objc func handleGetURLEvent(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue{
            Logger.shared.verbose("收到来自 URLScheme 的上传请求: \(urlString)")
            URLSchemeExt.shared.handleURL(urlString)
        } else {
            Logger.shared.warn("收到来自 URLScheme 的上传请求: 无效参数")
        }
    }
}
// MARK: - Statusbar
extension AppDelegate {
    
    func setupStatusBar() {
        Logger.shared.verbose("Setup status bar")

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
            indicator.controlTint = .blueControlTint
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
            button.window?.registerForDraggedTypes([.URL, .fileURL, .string, .html])
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
            if uploading {
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

// MARK: - 上传方式选择
extension AppDelegate {
    
    // 选择文件上传
    @objc func selectFile() {
        Logger.shared.info("选择文件上传")
        
        if self.uploading {
            Logger.shared.warn("当前上传任务未结束")
            NotificationExt.shared.postUplodingNotice()
            return
        }
        
        let fileExtensions = BaseUploader.getFileExtensions()
        
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        
        if fileExtensions.count > 0 {
            openPanel.allowedContentTypes = fileExtensions.compactMap { UTType(filenameExtension: $0) }
        }
        
        openPanel.begin { (result) -> Void in
            openPanel.close()
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                Logger.shared.info("选择文件文件数：\(openPanel.urls.count)")
                self.uploadFiles(openPanel.urls)
            }
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // 从剪切板上传
    @objc func uploadByPasteboard() {
        Logger.shared.info("从剪切板上传")
        
        if self.uploading {
            Logger.shared.warn("当前上传任务未结束")
            NotificationExt.shared.postUplodingNotice()
            return
        }
        
        Logger.shared.info("剪切板上传格式:\(NSPasteboard.general.types?.first?.rawValue ?? "")")
        
        if let filenames = NSPasteboard.general.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] {
            let fileExtensions = BaseUploader.getFileExtensions()
            var urls = [URL]()
            
            for path in filenames {
                if (fileExtensions.count == 0 || fileExtensions.contains(path.pathExtension.lowercased())) {
                    urls.append(URL(fileURLWithPath: path))
                }
            }
            
            
            Logger.shared.info("剪切板上传文件，获取到文件数：\(urls.count)")
            
            if urls.count > 0 {
                Logger.shared.info("剪切板上传文件数：\(urls.count)")
                self.uploadFiles(urls)
            } else {
                Logger.shared.warn("剪切板文件格式不支持")
                NotificationExt.shared.postUploadErrorNotice("File format not supported!".localized)
            }
            
        } else if (NSPasteboard.general.types?.first == NSPasteboard.PasteboardType.png) {
            Logger.shared.info("剪切板上传 PNG")
            let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.png)
            self.uploadFiles([imgData!])
        } else if (NSPasteboard.general.types?.first == NSPasteboard.PasteboardType.jpeg) {
            Logger.shared.info("剪切板上传 JPEG")
            let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.jpeg)
            self.uploadFiles([imgData!])
        } else if (NSPasteboard.general.types?.first == NSPasteboard.PasteboardType.tiff) {
            Logger.shared.info("剪切板上传 TIFF")
            let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.tiff)
            if let jpg = imgData?.convertImageData(.jpeg) {
                self.uploadFiles([jpg])
            }
        } else {
            Logger.shared.info("剪切板上传其他格式")
            if let urlStr = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.string) {
                if let url = URL(string: urlStr.urlEncoded()), let data = try? Data(contentsOf: url)  {
                    Logger.shared.info("剪切板上传其他格式，获取到 Data")
                    self.uploadFiles([data])
                }
            }
        }
        
    }
    
    
    // 截图上传
    @objc func screenshotAndUpload() {
        Logger.shared.info("截图上传")
        
        if self.uploading {
            Logger.shared.warn("当前上传任务未结束")
            NotificationExt.shared.postUplodingNotice()
            return
        }
        
        if ScreenUtil.getScreenshotApp() == .system {
            Logger.shared.info("使用 macOS 自带截图工具截图")
            
            // 截图权限检测
            Logger.shared.verbose("检查屏幕录制权限")
            let hasPermission = ScreenUtil.screeningRecordPermissionCheck()
            if !hasPermission {
                Logger.shared.warn("无截图权限，申请截图权限并弹出帮助界面、跳转到设置界面")
                // 无截图权限，申请截图权限并弹出帮助界面、跳转到设置界面
                ScreenUtil.requestRecordScreenPermissions()
                
                _ = WindowManager.shared.showWindow(storyboard: "ScreenshotAuthorizationHelp", withIdentifier: "screenshotAuthorizationHelpWindowController")
                return
            }
            Logger.shared.verbose("屏幕录制权限已获取， 开始截图")
            
            let task = Process()
            task.launchPath = "/usr/sbin/screencapture"
            task.arguments = ["-i", "-c"]
            task.launch()
            task.waitUntilExit()
            
            Logger.shared.info("截图上传格式:\(NSPasteboard.general.types?.first?.rawValue ?? "")")
            if (NSPasteboard.general.types?.first == NSPasteboard.PasteboardType.png) {
                Logger.shared.info("截图上传 PNG")
                let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.png)
                self.uploadFiles([imgData!])
            } else if (NSPasteboard.general.types?.first == NSPasteboard.PasteboardType.jpeg) {
                Logger.shared.info("截图上传 JPEG")
                let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.jpeg)
                self.uploadFiles([imgData!])
            }
            
        } else if ScreenUtil.getScreenshotApp() == .longshot {
            Logger.shared.info("使用 Longshot 截图")
            guard let url = URL(string: "longshot://x-callback-url/snip?func=start&channel=clipboard&type=data&x-source=uPic&x-success=uPic://x-callback-url/acceptSnip?x-source=longshot&x-error=uPic://x-callback-url/snipError?x-source=longshot&errorMessage=message") else {
                return
            }
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Drag and drop file upload
extension AppDelegate: NSWindowDelegate, NSDraggingDestination {
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.draggingData = sender.draggedFromBrowserData
        
        if sender.draggedFileUrls.count > 0 || draggingData != nil || sender.draggedFromBrowserUrl != nil {
            if let statusItem = statusItem, let button = statusItem.button {
                button.image = NSImage(named: "uploadIcon")
            }
            return .copy
        }
        return .generic
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        Logger.shared.info("拖拽到图标上传: \(sender.draggedFileUrls.count)")
        
        if sender.draggedFileUrls.count > 0 || self.draggingData != nil || sender.draggedFromBrowserUrl != nil {
            self.setStatusBarIcon(isIndicator: false)
            if sender.draggedFileUrls.count > 0 {
                self.uploadFiles(sender.draggedFileUrls)
                return true
            } else if let imageData = self.draggingData {
                self.uploadFiles([imageData])
                self.draggingData = nil
                return true
            } else if let url = sender.draggedFromBrowserUrl {
                self.uploadFiles([url])
                return true
            }
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

// 上传方法
extension AppDelegate {
    // 解析以 , 分割的多个文件路径并上传
    func uploadFilesFromPaths(_ pathStr: String) {
        let paths = pathStr.split(separator: Character(","))

        Logger.shared.verbose("解析到 \(paths.count) 个文件路径")
        
        let fileExtensions = BaseUploader.getFileExtensions()
        var urls = [URL]()
        
        for path in paths {
            let sPath = String(path)
            let url = URL(fileURLWithPath: sPath)
            
            if (fileExtensions.count == 0 || fileExtensions.contains(url.pathExtension.lowercased())) {
                urls.append(url)
            }
        }
        
        if (urls.count == 0) {
            Logger.shared.error("文件格式不支持-\(pathStr)")
            NotificationExt.shared.postUploadErrorNotice("File format not supported!".localized)
            return
        }
        
        self.uploadFiles(urls)
    }
    
    // 上传多个文件，所有上传方式的入口
    func uploadFiles(_ files: [Any], _ uploadSourceType: UploadSourceType? = .normal,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
        
        Logger.shared.info("执行上传操作", file: file, function: function, line: line)
        
        var uploadFiles = files
        
        if let urls = files as? [URL] {
            // 如果是文件路径，处理文件夹
            var uploadUrls: [URL] = []
            for url in urls {
                let path = url.path
                
                if FileManager.directoryIsExists(path: path) {
                    let directoryName = path.lastPathComponent
                    let enumerator = FileManager.default.enumerator(atPath: path)
                    while let filename = enumerator?.nextObject() as? String {
                        let subPath = path.appendingPathComponent(path: filename)
                        if FileManager.directoryIsExists(path: subPath) {
                            continue
                        }
                        if !BaseUploader.checkFileExtensions(fileExtensions: BaseUploader.getFileExtensions(), fileExtension: filename.pathExtension) {
                            continue
                        }
                        let subDirectoryPath = filename.deletingLastPathComponent
                        let directoryPath = directoryName.appendingPathComponent(path: subDirectoryPath)
                        var subUrl = URL(fileURLWithPath: subPath)
                        subUrl._uploadFolderPath = directoryPath
                        uploadUrls.append(subUrl)
                    }
                } else {
                    uploadUrls.append(url)
                }
            }
            uploadFiles = uploadUrls
        }
        
        self.uploadSourceType = uploadSourceType
        
        self.needUploadFiles = uploadFiles
        self.resultUrls.removeAll()
        
        if self.needUploadFiles.count == 0 {
            // MARK: - Cli Support
            if self.uploadSourceType == UploadSourceType.cli {
                DispatchQueue.main.async {
                    exit(EX_OK)
                }
            }
            return
        }

        // 开始磁盘授权访问
        _ = DiskPermissionManager.shared.startDirectoryAccessing()
        
        // 检查磁盘访问权限
        if !DiskPermissionManager.shared.checkFullDiskAuthorizationStatus() {
            Logger.shared.warn("没有完全磁盘访问权限，可能影响文件上传")
        }
        
        self.uploading = true
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
                if !FileManager.default.isReadableFile(atPath: (firstFile as! URL).path) {
                    NotificationExt.shared.postFileNoAccessNotice()
                    tickFileToUpload()
                    return
                }
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
    func uploadFaild(errorMsg: String?, detailMsg: String? = nil,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
        
        var logMsg = "上传失败：\(errorMsg ?? "")"
        if let detailMsg = detailMsg {
            logMsg = "\(logMsg): \(detailMsg))"
        }
        Logger.shared.error(logMsg, file: file, function: function, line: line)
        
        self.setStatusBarIcon(isIndicator: false)
        // MARK: - Cli Support
        if self.uploadSourceType == UploadSourceType.cli {
            Cli.shared.uploadError(errorMsg ?? detailMsg ?? "")
        } else {
            NotificationExt.shared.postUploadErrorNotice(errorMsg ?? detailMsg ?? "")
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
        Logger.shared.warn("取消上传")
        self.setStatusBarIcon(isIndicator: false)
        BaseUploader.cancelUpload()
        self.needUploadFiles.removeAll()
        self.resultUrls.removeAll()
        self.uploading = false
    }
    
    func uploadDone() {
        Logger.shared.info("上传任务结束：\(self.resultUrls.joined(separator: " | "))")
        
        // 停止磁盘授权访问
        DiskPermissionManager.shared.stopDirectoryAccessing()
        
        self.uploading = false
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
        Logger.shared.verbose("准备复制上传结果到剪切板->\(urls.joined(separator: ","))")

        let outputUrls = BaseUploaderUtil.formatOutputUrls(urls)
        let outputStr = outputUrls.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(outputStr, forType: .string)

        Logger.shared.verbose("复制上传结果到剪切板->\(outputStr)")
        
        return outputStr
    }
}
