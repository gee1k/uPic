//
//  ScreenUtil.swift
//  uPic
//
//  Created by Svend Jin on 2021/1/21.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa

class ScreenUtil {
    static func screeningRecordPermissionCheck() -> Bool {
        if #available(macOS 10.15, *) {
           let runningApplication = NSRunningApplication.current
           let processIdentifier = runningApplication.processIdentifier
           guard let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID)
                   as? [[String: AnyObject]],
                 let _ = windows.first(where: { (window) -> Bool in
                   guard let windowProcessIdentifier = (window[kCGWindowOwnerPID as String] as? Int).flatMap(pid_t.init),
                         windowProcessIdentifier != processIdentifier,
                         let windowRunningApplication = NSRunningApplication(processIdentifier: windowProcessIdentifier),
                         windowRunningApplication.executableURL?.lastPathComponent != "Dock",
                         let _ = window[String(kCGWindowName)] as? String else {
                       return false
                   }
                   
                   return true
                 }) else {
               return false
           }
       }
       return true
    }
    
    /// 请求屏幕权限
    static func requestRecordScreenPermissions() {
        if #available(macOS 10.15, *) {
            CGWindowListCreateImage(
                CGRect(x: 0, y: 0, width: 1, height: 1),
                .optionOnScreenOnly,
                kCGNullWindowID,
                []
            )
        }
    }
    
    /// 打开屏幕权限设置页
    static func openPrivacyScreenCapture() {
        if #available(macOS 10.15, *) {
            guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") else {
                return
            }
            NSWorkspace.shared.open(url)
        }
    }
}
