//
//  NotificationExt.swift
//  uPic
//
//  Created by Svend Jin on 2019/8/16.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import UserNotifications

class NotificationExt:NSObject {
    
    static let shared = NotificationExt()
    
    func post(title: String, info: String, subtitle: String? = nil) -> Void {
        if #available(OSX 10.14, *) {
            self.postByNew(title: title, info: info, subtitle: subtitle)
        } else {
            self.postByOld(title: title, info: info, subtitle: subtitle)
        }
    }
    
    func postUploadErrorNotice(_ body: String? = "") {
        self.post(title: NSLocalizedString("notification.upload.error.title", comment: ""),
                  info: body!)
    }
    
    func postUploadSuccessfulNotice(_ body: String? = "") {
        self.post(title: NSLocalizedString("notification.upload.success.title", comment: ""),
                  info: body!, subtitle: NSLocalizedString("notification.upload.success.subtitle", comment: ""))
    }
    
    func postCopySuccessfulNotice(_ body: String? = "") {
        self.post(title: NSLocalizedString("notification.upload.success.subtitle", comment: ""),
                  info: body!)
    }
    
    func postFileDoesNotExistNotice() {
        self.post(title: NSLocalizedString("notification.upload.error.title", comment: ""),
                  info: NSLocalizedString("file-does-not-exist", comment: ""))
    }
    
    func postUplodingNotice(_ body: String? = "") {
        self.post(title: NSLocalizedString("notification.upload.task-not-complete.subtitle", comment: ""),
                  info: body!)
    }
    
    
    func postImportErrorNotice(_ body: String? = NSLocalizedString("notification.import.error.body", comment: "")) {
        self.post(title: NSLocalizedString("notification.import.error.title", comment: ""),
                  info: body!)
    }
    
    func postImportSuccessfulNotice() {
        self.post(title: NSLocalizedString("notification.success.title", comment: ""),
                  info: NSLocalizedString("notification.import.success.body", comment: ""))
    }
    
    func postExportErrorNotice(_ body: String? = NSLocalizedString("notification.export.error.body.invalid", comment: "")) {
        self.post(title: NSLocalizedString("notification.upload.task-not-complete.subtitle", comment: ""),
                  info: body!)
    }
    
    func postExportSuccessfulNotice() {
        self.post(title: NSLocalizedString("notification.success.title", comment: ""),
                  info: NSLocalizedString("notification.export.success.body", comment: ""))
    }
}

@available(OSX 10.14, *)
extension NotificationExt: UNUserNotificationCenterDelegate {
    
    // MARK: Version Target >= 10.14
    
    func postByNew(title: String, info: String, subtitle: String? = nil) -> Void {
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
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (success, error) in
            if success {
                notificationCenter.add(request) { (error) in
                    if error != nil {
                        // Handle any errors.
                    }
                }
            } else {
                // user rejection
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
        completionHandler([.alert, .sound])
    }
}

extension NotificationExt: NSUserNotificationCenterDelegate {
    
    // MARK: Version Target < 10.14
    
    func postByOld(title: String, info: String, subtitle: String? = nil) {
        
        let notification = NSUserNotification()
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = info
        notification.userInfo = ["body": info]
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        if notification.activationType == .contentsClicked {
            if let userInfo = notification.userInfo, let body = userInfo["body"] {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.declareTypes([.string], owner: nil)
                NSPasteboard.general.setString(body as! String, forType: .string)
            }
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
}
