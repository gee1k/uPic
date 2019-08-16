//
//  NSUserNotificationCenter+Extension.swift
//  uPic
//
//  Created by Svend Jin on 2019/8/13.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

extension NSUserNotificationCenter {
    func post(title: String, info: String, subtitle: String? = nil) {
        self.removeAllDeliveredNotifications()
        
        let notification = NSUserNotification()
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = info
        notification.userInfo = ["body": info]
        notification.soundName = NSUserNotificationDefaultSoundName
        self.delegate = UserNotificationCenterDelegate.shared
        self.deliver(notification)
    }

    func postUploadErrorNotice(_ body: String? = "") {
        self.post(title: NSLocalizedString("upload.notification.error.title", comment: ""),
                  info: body!)
    }

    func postUploadSuccessfulNotice(_ body: String? = "") {
        self.post(title: NSLocalizedString("upload.notification.success.title", comment: ""),
                  info: body!, subtitle: NSLocalizedString("upload.notification.success.subtitle", comment: ""))
    }

    func postCopySuccessfulNotice(_ body: String? = "") {
        self.post(title: NSLocalizedString("upload.notification.success.subtitle", comment: ""),
                  info: body!)
    }

    func postFileDoesNotExistNotice() {
        self.post(title: NSLocalizedString("upload.notification.error.title", comment: ""),
                  info: NSLocalizedString("file-does-not-exist", comment: ""))
    }

    func postUplodingNotice(_ body: String? = "") {
        self.post(title: NSLocalizedString("upload.notification.task-not-complete.subtitle", comment: ""),
                  info: body!)
    }

}

class UserNotificationCenterDelegate: NSObject, NSUserNotificationCenterDelegate {
    static let shared = UserNotificationCenterDelegate()

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
