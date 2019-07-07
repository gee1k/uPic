//
//  NotificationExt.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/8.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import UserNotifications

class NotificationExt: NSObject {
    static let shared = NotificationExt()
    
    func sendNotification(title: String, subTitle: String, body: String) -> Void {
        if #available(OSX 10.14, *) {
            self.sendNotificationByNew(title: title, subTitle: subTitle, body: body)
        } else {
            self.sendNotificationByOld(title: title, subTitle: subTitle, body: body)
        }
    }

    ///
    /// 发送上传失败通知
    ///
    static func sendUploadErrorNotification(body: String? = "") {
        NotificationExt.shared.sendNotification(title: NSLocalizedString("upload.notification.error.title", comment: "上传失败通知标题"), subTitle: "", body: body!)
    }

    ///
    /// 发送上传成功通知
    ///
    static func sendUploadSuccessfulNotification(body: String? = "") {

        NotificationExt.shared.sendNotification(title: NSLocalizedString("upload.notification.success.title", comment: "上传成功通知标题"), subTitle: NSLocalizedString("upload.notification.success.subtitle", comment: "上传成功通知副标题"), body: body!)
    }
    
    ///
    /// 发送拷贝成功通知
    ///
    static func sendCopySuccessfulNotification(body: String? = "") {
        
        NotificationExt.shared.sendNotification(title: NSLocalizedString("notification.success.title", comment: "成功通知标题"), subTitle: NSLocalizedString("upload.notification.success.subtitle", comment: "上传成功通知副标题"), body: body!)
    }


    ///
    /// 发送文件不存在通知
    ///
    static func sendFileDoesNotExistNotification() {

        NotificationExt.shared.sendNotification(title: NSLocalizedString("upload.notification.error.title", comment: "上传失败"), subTitle: "", body: NSLocalizedString("file-does-not-exist", comment: "文件不存在或已被删除"))
    }

    ///
    /// 发送开始上传通知
    ///
    static func sendStartUploadNotification(body: String? = "") {
        NotificationExt.shared.sendNotification(title: NSLocalizedString("upload.notification.start.title", comment: "开始上传通知标题"), subTitle: NSLocalizedString("upload.notification.start.subtitle", comment: "开始上传通知副标题"), body: body!)
    }

    ///
    /// 发送当前上传任务还未完成通知
    ///
    static func sendUplodingNotification(body: String? = "") {
        NotificationExt.shared.sendNotification(title: NSLocalizedString("upload.notification.warning.title", comment: ""), subTitle: NSLocalizedString("upload.notification.task-not-complete.subtitle", comment: ""), body: body!)
    }

}

@available(OSX 10.14, *)
extension NotificationExt: UNUserNotificationCenterDelegate {
    
    
    // MARK: Version Target >= 10.14
    
    func sendNotificationByNew(title: String, subTitle: String, body: String) -> Void {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        content.body = body
        
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "NOTIFICATION_U_PIC"
        content.userInfo = ["body": body]
        
        let request = UNNotificationRequest(identifier: "U_PIC_REQUEST",
                                            content: content,
                                            trigger: nil)
        
        
        let category = UNNotificationCategory(identifier: "U_PIC_CATEGORY",
                                              actions: [],
                                              intentIdentifiers: [],
                                              hiddenPreviewsBodyPlaceholder: "",
                                              options: .customDismissAction)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.delegate = self
        notificationCenter.setNotificationCategories([category])
        notificationCenter.add(request) { (error) in
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
        completionHandler([.alert, .sound])
    }
}

extension NotificationExt: NSUserNotificationCenterDelegate {
    
    // MARK: Version Target < 10.14
    
    func sendNotificationByOld(title: String, subTitle: String, body: String) -> Void {
        
        NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        
        let userNotification = NSUserNotification()
        
        userNotification.title = title
        userNotification.subtitle = subTitle
        userNotification.informativeText = body
        
        userNotification.identifier = "OLD_NOTIFICATION_U_PIC"
        userNotification.userInfo = ["body": "body"]
        
        userNotification.soundName = NSUserNotificationDefaultSoundName
        
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.deliver(userNotification)
        
    }
    
    // 当 App 在前台时是否弹出通知
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    // 推送消息后的回调
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        print("\(Date(timeIntervalSinceNow: 0)) -> 消息已经推送")
    }
    
    // 用户点击了通知后的回调
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        
        if notification.activationType == .contentsClicked {
            if let userInfo = notification.userInfo, let body = userInfo["body"] {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.declareTypes([.string], owner: nil)
                NSPasteboard.general.setString(body as! String, forType: .string)
            }
        }
    }
    
}
