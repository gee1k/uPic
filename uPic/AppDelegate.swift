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
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /* 状态栏菜单 */
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
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
        let menuItem = NSMenuItem(title: NSLocalizedString("status-menu.select", comment: "选择文件"), action: #selector(AppDelegate.selectFile(_:)), keyEquivalent: "P")
        menuItem.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        menu.addItem(menuItem)
        
        menu.addItem(NSMenuItem(title: NSLocalizedString("status-menu.clear", comment: "清除历史上传"), action: #selector(clearHistory), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        self.createOutputFormatMenu(menu: menu)
        menu.addItem(NSMenuItem(title: NSLocalizedString("status-menu.about", comment: "关于"), action: #selector(showAboutMe), keyEquivalent: ""))
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
        openPanel.allowedFileTypes = ["png", "jpg", "jpeg", "svg", "gif"]
        openPanel.begin { (result) -> Void in
            openPanel.close()
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                let selectedPath = openPanel.url!.path
                let url: URL = URL(fileURLWithPath: selectedPath)
                
                
                AF.upload(multipartFormData: { (multipartFormData:MultipartFormData) in
                    multipartFormData.append(url, withName: "smfile")
                }, to: "https://sm.ms/api/upload", method: HTTPMethod.post).responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let code = json["code"]
                        if "error" == code {
                            let msg = json["msg"].stringValue
                            debugPrint(msg)
                            self.sendNotification(title: NSLocalizedString("upload.notification.error.title", comment: "上传失败通知标题"), subTitle: "", body: msg)
                        } else {
                            let data = json["data"]
                            self.onUploadSuccess(data: data)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                
            }
        }
    }
    
    @objc func showAboutMe() {
        
        let infoDic = Bundle.main.infoDictionary
        let appNameStr = NSLocalizedString("app-name", comment: "APP 名称")
        let versionStr = infoDic?["CFBundleShortVersionString"] as! String
        let appInfo =  appNameStr + " v" + versionStr
        
        let alert = NSAlert()
        alert.alertStyle = NSAlert.Style.informational
        alert.messageText = NSLocalizedString("about-window.title", comment: "关于窗口的标题：关于")
        alert.informativeText = "\(appInfo) \(NSLocalizedString("about-window.message", comment: "关于窗口的消息：上传图片到 https://sm.ms")) \n\nAuthor: Svend Jin \nWebsite: https://svend.cc \nGithub: https://github.com/gee1k/uPic"
        let button = NSButton(title: "Github", target: nil, action: #selector(openGithub))
        alert.accessoryView = button
        alert.addButton(withTitle: NSLocalizedString("alert-info-button.titile", comment: "提示窗口确定按钮的标题：确定"))
        alert.window.titlebarAppearsTransparent = true
        alert.runModal()
    }
    
    @objc func openGithub() {
        if let url = URL(string: "https://github.com/gee1k/uPic"), NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
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
        AF.request("https://sm.ms/api/clear").validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let code = json["code"]
                let msg = json["msg"].stringValue
                let title = "error" == code ? NSLocalizedString("clear.notification.error.title", comment: "清除历史上传失败通知标题") : NSLocalizedString("clear.notification.success.title", comment: "清除历史上传失败通知标题")
                self.sendNotification(title: title, subTitle: "", body: msg)
            case .failure(let error):
                print(error)
            }
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
        
        self.sendNotification(title: NSLocalizedString("upload.notification.success.title", comment: "上传成功通知标题"), subTitle: NSLocalizedString("upload.notification.success.subtitle", comment: "上传成功通知副标题"), body: url)
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // MARK: 本地通知扩展
    
    func sendNotification(title: String, subTitle: String, body: String) -> Void {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        content.body = body
        
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "U_PIC"
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "U_PIC_REQUEST",
                                            content: content,
                                            trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.add(request) { (error) in
            if error != nil {
                // Handle any errors.
            }
        }
        
    }
    
    // 配置通知发起时的行为 alert -> 显示弹窗, sound -> 播放提示音
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
