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
    
    
    private func promptForWorkingDirectoryPermission(for directoryURL: URL = URL(fileURLWithPath: "/", isDirectory: true)) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.message = "Authorize".localized
        openPanel.prompt = "Authorize".localized
        openPanel.allowedFileTypes = ["none"]
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseDirectories = true
        openPanel.directoryURL = directoryURL

        openPanel.runModal()
        return openPanel.urls.first
    }
    
    private func saveBookmarkData(for workDir: URL, defaultKey: DefaultsKey<Data>) {
        do {
            let bookmarkData = try workDir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)

            // save in UserDefaults
            Defaults[defaultKey] = bookmarkData
        } catch {
            print("Failed to save bookmark data for \(workDir)", error)
        }
    }
    
    private func restoreFileAccess(with bookmarkData: Data, defaultKey: DefaultsKey<Data>) -> URL? {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                saveBookmarkData(for: url, defaultKey: defaultKey)
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
        guard let data = Defaults[.rootDirectoryBookmark] else {
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
        debugPrintOnly("开始授权根目录权限")
        guard let url = self.promptForWorkingDirectoryPermission() else {
            return
        }
        self.saveBookmarkData(for: url, defaultKey: .rootDirectoryBookmark)
        debugPrintOnly("授权根目录权限成功")
    }
    
    func cancelFullDiskPermissions() {
        debugPrintOnly("取消授权根目录权限")
        Defaults[.rootDirectoryBookmark] = nil
        debugPrintOnly("取消根目录权限成功")
    }
    
    func requestHomeDirectoryPermissions() {
        debugPrintOnly("开始授权主目录权限")
        guard let url = self.promptForWorkingDirectoryPermission(for: URL(fileURLWithPath: "~/", isDirectory: true)) else {
            return
        }
        self.saveBookmarkData(for: url, defaultKey: .homeDirectoryBookmark)
        debugPrintOnly("授权主目录权限成功")
    }
    
    // 获取安全授权，根目录授权优先获取，无根目录书签时获取主目录书签
    func startDirectoryAccessing() -> Bool {
        debugPrintOnly("开始获取安全授权")
        
        stopDirectoryAccessing()
        
        // 获取根目录授权书签
        if let data = Defaults[.rootDirectoryBookmark], let url = restoreFileAccess(with: data, defaultKey: .rootDirectoryBookmark) {
            
            workingDirectoryBookmarkUrl = url
            let flag = url.startAccessingSecurityScopedResource()
            debugPrintOnly("开始获取安全授权完成--根目录")
            return flag
        } else if let data = Defaults[.homeDirectoryBookmark], let url = restoreFileAccess(with: data, defaultKey: .homeDirectoryBookmark) {
            // 获取主目录授权书签
            
            workingDirectoryBookmarkUrl = url
            let flag = url.startAccessingSecurityScopedResource()
            debugPrintOnly("开始获取安全授权完成--用户主目录")
            return flag
        }
        
        return false
    }
    
    func stopDirectoryAccessing() {
        debugPrintOnly("开始停止获取安全授权")
        guard let url = workingDirectoryBookmarkUrl else {
            return
        }
        url.stopAccessingSecurityScopedResource()
        workingDirectoryBookmarkUrl = nil
        debugPrintOnly("停止获取安全授权完成")
    }
}
