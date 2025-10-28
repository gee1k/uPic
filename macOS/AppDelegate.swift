//
//  AppDelegate.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import AppKit
import KeyboardShortcuts

class AppDelegate: NSResponder, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        setupKeyboardShortcuts()
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
}
