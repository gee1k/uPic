//
//  AppDelegate.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import AppKit
import KeyboardShortcuts

class AppDelegate: NSResponder, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {}

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        return true
    }

    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .uploadFromSelectFile) {}
        KeyboardShortcuts.onKeyUp(for: .uploadFromClipboard) {}
        KeyboardShortcuts.onKeyUp(for: .uploadFromScreenshot) {}
    }
}
