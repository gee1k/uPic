//
//  Util.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/9.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON

func getAppInfo() -> String {
    let infoDic = Bundle.main.infoDictionary
    let appNameStr = "APP Name".localized
    let versionStr = infoDic?["CFBundleShortVersionString"] as! String
    return appNameStr + " v" + versionStr
}

func alertInfo(withText: String, withMessage: String) {
    let alert = NSAlert()
    alert.messageText = withText
    alert.informativeText = withMessage
    alert.addButton(withTitle: "OK".localized)
    alert.window.titlebarAppearsTransparent = true
    alert.runModal()
}

func alertInfo(withText messageText: String, withMessage message: String, oKButtonTitle: String, cancelButtonTitle: String, okHandler: @escaping (() -> Void)) {
    let alert = NSAlert()
    alert.alertStyle = NSAlert.Style.informational
    alert.messageText = messageText
    alert.informativeText = message
    alert.addButton(withTitle: oKButtonTitle)
    alert.addButton(withTitle: cancelButtonTitle)
    alert.window.titlebarAppearsTransparent = true
    if alert.runModal() == .alertFirstButtonReturn {
        okHandler()
    }
}

func promptForWorkingDirectoryPermission() -> URL? {
    let openPanel = NSOpenPanel()
    openPanel.prompt = "Authorize".localized
    openPanel.allowedFileTypes = ["none"]
    openPanel.allowsOtherFileTypes = false
    openPanel.canChooseFiles = false
    openPanel.canCreateDirectories = false
    openPanel.canChooseDirectories = true
    openPanel.directoryURL = URL(fileURLWithPath: "file://")

    openPanel.runModal()
    print(openPanel.urls) // this contains the chosen folder
    return openPanel.urls.first
}

func saveBookmark(url: URL?) {
    guard let url = url else { return  }
    do {
        let bookmarkData = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        
        Defaults[.workingDirectoryBookmark] = bookmarkData
    } catch {
        print("Failed to save bookmark data for \(url)", error)
    }
}

func loadBookmark(data: Data?) -> URL? {
    guard let data = data else { return nil }
    do {
        var isStale = false
        let url = try URL(
            resolvingBookmarkData: data,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        
        if isStale {
            // bookmarks could become stale as the OS changes
            print("Bookmark is stale, need to save a new one... ")
            saveBookmark(url: url)
        }
        return url
    } catch {
        print("Error resolving bookmark:", error)
        return nil
    }
}
