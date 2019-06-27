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

    lazy var preferencesWindowController: PreferencesWindowController = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? PreferencesWindowController ?? PreferencesWindowController()
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

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

        NSApp.activate(ignoringOtherApps: true)
        let fileExtensions = BaseUploader.getFileExtensions()

        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true

        if fileExtensions.count > 0 {
            openPanel.allowedFileTypes = fileExtensions
        }

        openPanel.begin { (result) -> Void in
            openPanel.close()
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                let selectedPath = openPanel.url!.path
                let url: URL = URL(fileURLWithPath: selectedPath)

                self.uploadFile(url, data: nil)
            }
        }
    }

    @objc func uploadByPasteboard() {
        let pasteboardType = NSPasteboard.general.types?.first

        if (pasteboardType == NSPasteboard.PasteboardType.png) {
            let imgData = NSPasteboard.general.data(forType: NSPasteboard.PasteboardType.png)
            self.uploadFile(nil, data: imgData!)
        } else if (pasteboardType == NSPasteboard.PasteboardType.backwardsCompatibleFileURL) {

            let filePath = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.backwardsCompatibleFileURL)!
            let url = URL(string: filePath)!

            let fileManager = FileManager.default
            if (!url.isFileURL || !fileManager.fileExists(atPath: url.path)) {
                debugPrint("复制的文件不存在或已被删除！")
                NotificationExt.sendFileDoesNotExistNotification()
                return
            }
            self.uploadFile(url, data: nil)
        } else {
            self.uploadFaild(errorMsg: NSLocalizedString("file-format-is-not-supported", comment: "文件格式不支持"))
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


    @objc func checkUpdate() {
        UPicUpdater.shared.check() {
        }
    }


    func uploadFile(_ url: URL?, data: Data?) {
        if url != nil {
            BaseUploader.upload(url: url!)
        } else if (data != nil) {
            BaseUploader.upload(data: data!)
        }
    }

    ///
    /// 上传成功时被调用
    ///
    func uploadCompleted(url: String) {
        self.setStatusBarIcon(isIndicator: false)
        let outputUrl = self.copyUrl(url: url)
        NotificationExt.sendUploadSuccessfulNotification(body: outputUrl)
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

    ///
    /// 上传失败时被调用
    ///
    func uploadFaild(errorMsg: String? = "") {
        self.setStatusBarIcon(isIndicator: false)
        NotificationExt.sendUploadErrorNotification(body: errorMsg)
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
        NotificationExt.sendStartUploadNotification()
    }
}

extension AppDelegate: NSWindowDelegate, NSDraggingDestination {

    // MARK: 拖拽文件

    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.isValidFile {
            if let button = statusItem.button {
                button.image = NSImage(named: "uploadIcon")
            }
            return .copy
        }
        return .generic
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // TODO: 需要支持所有格式文件/根据图床支持的格式再进行判断
        if sender.isValidFile {
            let fileUrl = sender.draggedFileURL!.absoluteURL
            self.setStatusBarIcon()
            self.uploadFile(fileUrl, data: nil)
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
