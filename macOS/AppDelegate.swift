//
//  AppDelegate.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import AppKit
import KeyboardShortcuts
import SimpleLogger
import SwiftUI

class AppDelegate: NSResponder, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    @Environment(\.openWindow) var openWindow

    func applicationWillFinishLaunching(_: Notification) {
        Noti.shared.requestNotificationAuthorization()

        // Add URL scheme listening
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleGetURLEvent(event:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        NSApp.activate(ignoringOtherApps: true)
        openWindow(id: "settings")
        return true
    }

    @objc func handleGetURLEvent(event: NSAppleEventDescriptor!, withReplyEvent _: NSAppleEventDescriptor!) {
        if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue?.removingPercentEncoding {
            AppLogger.urlScheme.info("Received upload request from URLScheme: \(urlString)")
            Task {
                await URLSchemeManager.shared.handleURL(urlString)
            }
        } else {
            AppLogger.urlScheme.warning("Received upload request from URLScheme: invalid parameter")
        }
    }
}

extension AppDelegate: NSWindowDelegate, NSDraggingDestination {
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggedFileUrls.count > 0 || sender.draggedFromBrowserData != nil || sender.draggedFromBrowserUrl != nil {
            if let statusItem = statusItem, let button = statusItem.button {
                button.image = NSImage(named: "statusMenuUploadingIcon")
            }
            return .copy
        }
        return .generic
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        AppLogger.uploader.info("Drag to status item to upload: \(sender.draggedFileUrls.count)")

        if sender.draggedFileUrls.count > 0 || sender.draggedFromBrowserData != nil || sender.draggedFromBrowserUrl != nil {
            if sender.draggedFileUrls.count > 0 {
                Task {
                    await UploadManager.shared.upload(fileURLs: sender.draggedFileUrls)
                }
                return true
            } else if let imageData = sender.draggedFromBrowserData {
                Task {
                    await UploadManager.shared.upload(fileData: imageData)
                }
                return true
            } else if let url = sender.draggedFromBrowserUrl {
                Task {
                    await UploadManager.shared.upload(fileURLs: [url])
                }
                return true
            }
        }
        return false
    }

    func prepareForDragOperation(_: NSDraggingInfo) -> Bool {
        return true
    }

    func draggingExited(_: NSDraggingInfo?) {}

    func draggingEnded(_: NSDraggingInfo) {}
}
