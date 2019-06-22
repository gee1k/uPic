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
    
    // MARK: 本地通知扩展
    
    func sendNotification(title: String, subTitle: String, body: String) -> Void {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subTitle
        content.body = body

        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "U_PIC"
        content.userInfo = ["url": body]
        
        let request = UNNotificationRequest(identifier: "U_PIC_REQUEST",
                                            content: content,
                                            trigger: nil)
        
        
        let category = UNNotificationCategory(identifier: "U_PIC_CATEGORY",
                                              actions: [],
                                              intentIdentifiers: [],
                                              hiddenPreviewsBodyPlaceholder: "",
                                              options: .customDismissAction)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.setNotificationCategories([category])
        notificationCenter.add(request) { (error) in
            if error != nil {
                // Handle any errors.
            }
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
    
    
}

extension NotificationExt: UNUserNotificationCenterDelegate {
    
    // 用户点击弹窗后的回调
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let url = userInfo["url"] {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.declareTypes([.string], owner: nil)
            NSPasteboard.general.setString(url as! String, forType: .string)
        }
        
        completionHandler()
    }
    
    // 配置通知发起时的行为 alert -> 显示弹窗, sound -> 播放提示音
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
