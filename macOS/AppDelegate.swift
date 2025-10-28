//
//  AppDelegate.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import AppKit
import KeyboardShortcuts
import SimpleLogger

class AppDelegate: NSResponder, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        setupKeyboardShortcuts()
        
        Noti.shared.requestNotificationAuthorization()

        // Add URL scheme listening
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleGetURLEvent(event:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        return true
    }

    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .uploadFromSelectFile) {
            print("Upload from select file")
        }
        KeyboardShortcuts.onKeyUp(for: .uploadFromClipboard) {
            print("Upload from clipboard")
        }
        KeyboardShortcuts.onKeyUp(for: .uploadFromScreenshot) {
            print("Upload from screenshot")
        }
    }

    @objc func handleGetURLEvent(event: NSAppleEventDescriptor!, withReplyEvent _: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue {
            AppLogger.urlScheme.info("收到来自 URLScheme 的上传请求: \(urlString)")
            URLSchemeExt.shared.handleURL(urlString)
        } else {
            AppLogger.urlScheme.warning("收到来自 URLScheme 的上传请求: 无效参数")
        }
    }
}
