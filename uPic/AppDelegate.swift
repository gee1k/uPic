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
    
    @IBOutlet weak var statusItemMenu: NSMenu!
    
    lazy var preferencesWindowController: PreferencesWindowController = {
        let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
        return storyboard.instantiateInitialController() as? PreferencesWindowController ?? PreferencesWindowController()
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        setupStatusBar()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}

extension AppDelegate {
    
    func setupStatusBar() {
        if let button = statusItem.button {
            self.setStatusBarIcon()
            button.window?.delegate = self
            
            button.window?.registerForDraggedTypes([NSPasteboard.PasteboardType("NSFilenamesPboardType")])
        }
        
        statusItem.menu = statusItemMenu
    }
    
    func setStatusBarIcon() {
        let icon = NSImage(named:NSImage.Name("statusIcon"))
        icon!.isTemplate = true
        DispatchQueue.main.async {
            self.statusItem.button?.image = icon
        }
    }
    
    
}

extension AppDelegate {
    
    @objc func showPreference() {
        self.preferencesWindowController.showWindow(self)
    }
    
    /* 选择文件 */
    @objc func selectFile() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = SmmsUploader.imageTypes
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
        } else if (pasteboardType == NSPasteboard.PasteboardType.fileURL) {
            
            let filePath = NSPasteboard.general.string(forType: NSPasteboard.PasteboardType.fileURL)!
            let url = URL(string: filePath)!
            
            let fileManager = FileManager.default
            if (!url.isFileURL || !fileManager.fileExists(atPath: url.path)) {
                debugPrint("复制的文件不存在或已被删除！")
                NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.error.title", comment: "上传失败"), subTitle: "", body: NSLocalizedString("copied-file-does-not-exist", comment: "复制的文件不存在或已被删除"))
                return
            }
            self.uploadFile(url, data: nil)
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
    
    
    @objc func checkUpdate() {
        UPicUpdater.share.check(){}
    }
    
    
    func uploadFile(_ url:URL?, data: Data?) {
        if url != nil {
            if (!SmmsUploader.imageTypes.contains(url!.pathExtension)) {
                NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.error.title", comment: "上传失败"), subTitle: "", body: NSLocalizedString("copied-file-format-is-not-supported", comment: "复制的文件格式不支持"))
                return
            }
            SmmsUploader.share.upload(url!, callback: self.uploadCallBack)
        } else if (data != nil) {
            SmmsUploader.share.upload(data!, callback: self.uploadCallBack)
            
        }
    }
    
    func uploadCallBack(url: String, error: Error?) {
        
        if error != nil {
            NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.error.title", comment: "上传失败通知标题"), subTitle: "", body: error!.localizedDescription)
        }
        
        var outputUrl = ""
        let outputFormat = self.getOutputFormat()
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
        
        NotificationExt.share.sendNotification(title: NSLocalizedString("upload.notification.success.title", comment: "上传成功通知标题"), subTitle: NSLocalizedString("upload.notification.success.subtitle", comment: "上传成功通知副标题"), body: url)
    }
    
}

extension AppDelegate: NSWindowDelegate, NSDraggingDestination {
    
    // MARK: 拖拽文件
    
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
        // TODO: 需要支持所有格式文件/根据图床支持的格式再进行判断
        if sender.isImageFile {
            let imgurl = sender.draggedFileURL!.absoluteURL
            let imgData = NSData(contentsOf: imgurl!)
            self.uploadFile(nil, data: imgData! as Data)
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
