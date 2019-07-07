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
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let indicator = NSProgressIndicator()

    @IBOutlet weak var statusItemMenu: NSMenu!

    var uploding = false
    var needUploadFiles = [Any]()
    var resultUrls = [String]()

    lazy var preferencesWindowController: PreferencesWindowController = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? PreferencesWindowController ?? PreferencesWindowController()
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        self.resetNewVersionLaunchAtLogin()

        indicator.minValue = 0.0
        indicator.maxValue = 1.0
        indicator.doubleValue = 0.0
        indicator.isIndeterminate = false
        indicator.controlSize = NSControl.ControlSize.small
        indicator.style = NSProgressIndicator.Style.spinning
        indicator.isHidden = true

        setupStatusBar()
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSStatusBar.system.removeStatusItem(statusItem)
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
        }

        statusItem.menu = statusItemMenu
    }

    func setStatusBarIcon(isIndicator: Bool = false) {

        if isIndicator {
            DispatchQueue.main.async {
                self.statusItem.button?.image = nil
                self.indicator.doubleValue = 0.0
                self.indicator.isHidden = false
            }

        } else {
            let icon = NSImage(named: NSImage.Name("statusIcon"))
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
            NotificationExt.sendUplodingNotification()
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
            NotificationExt.sendUplodingNotification()
            return
        }
        
        if let filenames = NSPasteboard.general.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] {
            let fileExtensions = BaseUploader.getFileExtensions()
            var urls = [URL]()
            
            for path in filenames {
                if fileExtensions.contains(path.pathExtension.lowercased()) {
                    urls.append(URL(fileURLWithPath: path))
                }
            }
            if urls.count > 0 {
                self.uploadFiles(urls)
            } else {
                NotificationExt.sendUploadErrorNotification(body: NSLocalizedString("file-format-is-not-supported", comment: "文件格式不支持"))
            }
        }
    }

    @objc func screenshotAndUpload() {

        if self.uploding {
            NotificationExt.sendUplodingNotification()
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
        UPicUpdater.shared.check() {
        }
    }

    // 上传多个文件
    func uploadFiles(_ files: [Any]) {
        self.needUploadFiles = files
        self.resultUrls.removeAll()

        if self.needUploadFiles.count == 0 {
            return
        }

        NotificationExt.sendStartUploadNotification()
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
                NotificationExt.sendUploadSuccessfulNotification(body: outputStr)
                self.resultUrls.removeAll()
            }
        } else {
            // next file
            let firstFile = self.needUploadFiles.first
            if firstFile is URL {
                BaseUploader.upload(url: firstFile as! URL)
            } else if firstFile is Data {
                BaseUploader.upload(data: firstFile as! Data)
            }
            self.needUploadFiles.removeFirst()
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
        NotificationExt.sendUploadErrorNotification(body: errorMsg)
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
    
    func copyUrl(url: String) -> String {
        var outputUrl = ""
        let outputFormat = Defaults[.ouputFormat]
        switch outputFormat {
        case 1:
            outputUrl = "<img src='\(url)'/>"
            break
        case 2:
            outputUrl = "![pic](\(url))"
            break
        default:
            outputUrl = url
            
        }
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(outputUrl, forType: .string)
        
        return outputUrl
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
                outputUrl = "![pic](\(url))"
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
            var urls = [URL]()
            for url in sender.draggedFileURLs {
                urls.append(url.absoluteURL!)
            }
            self.uploadFiles(urls)
            return true
        }
        return false
    }

    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }

    func draggingExited(_ sender: NSDraggingInfo?) {
    }

    func draggingEnded(_ sender: NSDraggingInfo) {
    }

}
