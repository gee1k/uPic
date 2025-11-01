//
//  Noti.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import Cocoa
import Defaults
import SimpleLogger
import UserNotifications

class Noti: NSObject {
    static let shared = Noti()
}

extension Noti {
    func postUploadError(_ body: String? = "") {
        self.post(title: String(localized: "Upload failed"), body: body)
    }
    
    func postUploadSuccessful(_ body: String? = "") {
        self.post(title: String(localized: "Uploaded successfully"), subtitle: String(localized: "URL has been copied to the clipboard"), body: body)
    }
    
    func postCopySuccessful(_ body: String? = "") {
        self.post(title: String(localized: "URL has been copied to the clipboard"), body: body)
    }
    
    func postFileDoesNotExist() {
        self.post(title: String(localized: "Upload failed"), body: String(localized: "The file does not exist or has been deleted!"))
    }
    
    func postFileNoAccess() {
        self.post(title: String(localized: "Upload failed"), body: String(localized: "No access to file!"))
    }
    
    func postUploding(_ body: String? = "") {
        self.post(title: String(localized: "The current upload task is not complete"), body: body)
    }
    
    func postImportError(_ body: String? = String(localized: "The configuration file is invalid, please check!")) {
        self.post(title: String(localized: "Import failed"), body: body)
    }
    
    func postImportSuccessful() {
        self.post(title: String(localized: "Successfully"), body: String(localized: "The configuration has been imported, please check and use!"))
    }
    
    func postExportError(_ body: String? = String(localized: "Configuration export error!")) {
        self.post(title: String(localized: "The current upload task is not complete"), body: body)
    }
    
    func postExportSuccessful() {
        self.post(title: String(localized: "Successfully"), body: String(localized: "The configuration file is exported successfully, Do not modify the file contents!"))
    }
    
    func postAppIsAlreadyRunning() {
        self.post(title: "uPic", body: String(localized: "App is already running"))
    }
}

extension Noti: UNUserNotificationCenterDelegate {
    func post(title: String, subtitle: String = "", body: String? = nil) {
        guard Defaults[.sendNotification] else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body ?? ""
        content.sound = UNNotificationSound.default
        content.userInfo = ["body": body ?? ""]
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.setNotificationCategories([])
        
        notificationCenter.add(request) { error in
            if let error = error {
                AppLogger.notifications.error("Notification post falied: \(error.localizedDescription)")
            } else {
                AppLogger.notifications.info("Notification post successfully: title: \(title), body: \(body ?? "")")
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
        completionHandler([.list, .banner, .sound])
    }
}

extension Noti {
    // MARK: 请求通知权限
    
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                AppLogger.notifications.info("Notification permission granted")
            } else if let error = error {
                AppLogger.notifications.error("Notification permission request failed: \(error.localizedDescription)")
            } else {
                AppLogger.notifications.error("Notification permission denied")
            }
        }
    }
}
