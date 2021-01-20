//
//  DiskPermissionManager.swift
//  uPic
//
//  Created by Svend Jin on 2021/01/19.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa

public class DiskPermissionManager {
    
    // static
    public static var shared = DiskPermissionManager()
    
    // 储存当前开始授权访问的 URL 对象
    private var workingDirectoryBookmarkUrl: URL?
    
    
    private func promptForWorkingDirectoryPermission() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.message = "Authorize".localized
        openPanel.prompt = "Authorize".localized
        openPanel.allowedFileTypes = ["none"]
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseDirectories = true
        openPanel.directoryURL = URL(fileURLWithPath: "/", isDirectory: true)

        openPanel.runModal()
        return openPanel.urls.first
    }
    
    private func saveBookmarkData(for workDir: URL) {
        do {
            let bookmarkData = try workDir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)

            // save in UserDefaults
            Defaults[.workingDirectoryBookmark] = bookmarkData
        } catch {
            print("Failed to save bookmark data for \(workDir)", error)
        }
    }
    
    private func restoreFileAccess(with bookmarkData: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                saveBookmarkData(for: url)
            }
            return url
        } catch {
            print("Error resolving bookmark:", error)
            return nil
        }
    }
    
}

// Utils
extension DiskPermissionManager {
    
//    func initializeRequestDiskPermissions() {
//        if !Defaults[.requestedAuthorization] {
//            Defaults[.requestedAuthorization] = true
//            alertInfo(withText: "Full Disk Access".localized, withMessage: "Full Disk Access Message".localized, oKButtonTitle: "Authorize".localized, cancelButtonTitle: "Later".localized){ [self] in
//                requestFullDiskPermissions()
//            }
//        } else {
//            guard let data = Defaults[.workingDirectoryBookmark], let url = restoreFileAccess(with: data) else {
//                return
//            }
//            _ = url.startAccessingSecurityScopedResource()
//        }
//
//    }
    
    func checkFullDiskAuthorizationStatus() -> Bool {
        guard let data = Defaults[.workingDirectoryBookmark] else {
            return false
        }
        do {
            var isStale = true
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                return false
            }
            return url.path == "/"
        } catch {
            print("Error resolving bookmark:", error)
            return false
        }
    }
    
    func requestFullDiskPermissions() {
        debugPrint("开始授权")
        guard let url = self.promptForWorkingDirectoryPermission() else {
            debugPrint("取消授权")
            return
        }
        self.saveBookmarkData(for: url)
        debugPrint("授权成功")
    }
    
    func startFullDiskAccessing() -> Bool {
        debugPrint("开始获取安全授权")
        guard let data = Defaults[.workingDirectoryBookmark], let url = restoreFileAccess(with: data) else {
            return false
        }
        stopFullDiskAccessing()
        
        workingDirectoryBookmarkUrl = url
        let flag = url.startAccessingSecurityScopedResource()
        debugPrint("开始获取安全授权完成")
        return flag
    }
    
    func stopFullDiskAccessing() {
        debugPrint("开始停止获取安全授权")
        guard let url = workingDirectoryBookmarkUrl else {
            return
        }
        url.stopAccessingSecurityScopedResource()
        workingDirectoryBookmarkUrl = nil
        debugPrint("停止获取安全授权完成")
    }
}
