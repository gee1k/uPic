//
//  NotificationExt.swift
//  uPic
//
//  Created by Svend Jin on 2019/8/16.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SimpleLogger
import UserNotifications

class NotificationExt: NSObject {
    static let shared = NotificationExt()
    
    func post(title: String, info: String, subtitle: String? = nil) {
        self.postByNew(title: title, info: info, subtitle: subtitle)
    }
    
    func postUploadErrorNotice(_ body: String? = "") {
        self.post(title: String(localized: "Upload failed"), info: body!)
    }
    
    func postUploadSuccessfulNotice(_ body: String? = "") {
        self.post(title: String(localized: "Uploaded successfully"), info: body!, subtitle: String(localized: "URL has been copied to the clipboard, paste and use it!"))
    }
    
    func postCopySuccessfulNotice(_ body: String? = "") {
        self.post(title: String(localized: "URL has been copied to the clipboard, paste and use it!"), info: body!)
    }
    
    func postFileDoesNotExistNotice() {
        self.post(title: String(localized: "Upload failed"), info: String(localized: "The file does not exist or has been deleted!"))
    }
    
    func postFileNoAccessNotice() {
        self.post(title: String(localized: "Upload failed"), info: String(localized: "No access to file!"))
    }
    
    func postUplodingNotice(_ body: String? = "") {
        self.post(title: String(localized: "The current upload task is not complete"), info: body!)
    }
    
    func postImportErrorNotice(_ body: String? = String(localized: "The configuration file is invalid, please check!")) {
        self.post(title: String(localized: "Import failed"), info: body!)
    }
    
    func postImportSuccessfulNotice() {
        self.post(title: String(localized: "Successfully"), info: String(localized: "The configuration has been imported, please check and use!"))
    }
    
    func postExportErrorNotice(_ body: String? = String(localized: "configuration export error!")) {
        self.post(title: String(localized: "The current upload task is not complete"), info: body!)
    }
    
    func postExportSuccessfulNotice() {
        self.post(title: String(localized: "Successfully"), info: String(localized: "The configuration file is exported successfully, Do not modify the file contents!"))
    }
    
    func postAppIsAlreadyRunningNotice() {
        self.post(title: "uPic", info: String(localized: "App is already running"))
    }
}

extension NotificationExt: UNUserNotificationCenterDelegate {
    func postByNew(title: String, info: String, subtitle: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        content.body = info
        content.sound = UNNotificationSound.default
        content.userInfo = ["body": info]
        
        let request = UNNotificationRequest(identifier: "U_PIC_REQUEST_\(String.randomStr(len: 5))",
                                            content: content,
                                            trigger: nil)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.setNotificationCategories([])
        
        notificationCenter.add(request) { error in
            if error != nil {
                // Handle any errors.
            }
        }
    }
    
    // 用户点击弹窗后的回调
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let body = userInfo["body"] {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.declareTypes([.string], owner: nil)
            NSPasteboard.general.setString(body as! String, forType: .string)
        }
        
        completionHandler()
    }
    
    // 配置通知发起时的行为 alert -> 显示弹窗, sound -> 播放提示音
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
    }
}

extension NotificationExt {
    // MARK: 请求通知权限

    static func requestAuthorization() {
        AppLogger.notifications.info("Request notification authorization")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
            if success {
                // user accept
            } else {
                // user rejection
            }
        }
    }
}
