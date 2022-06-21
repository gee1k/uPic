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
        Logger.shared.verbose("开始检查是否有全盘访问权限")
        guard let data = Defaults[.rootDirectoryBookmark] else {
            Logger.shared.verbose("没有全盘访问权限-未找到书签")
            return false
        }
        do {
            var isStale = true
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                Logger.shared.verbose("没有全盘访问权限-书签已过期，需要保存一个新的...")
                return false
            }
            if (url.path == "/") {
                Logger.shared.verbose("有全盘访问权限")
                return true
            } else {
                Logger.shared.verbose("没有全盘访问权限-书签路径为\(url.path)")
                return false
            }
        } catch {
            print("Error resolving bookmark:", error)
            Logger.shared.error("没有全盘访问权限-书签错误\(error)")
            return false
        }
    }
    
    func requestFullDiskPermissions() {
        Logger.shared.verbose("开始授权根目录权限")
        guard let url = self.promptForWorkingDirectoryPermission() else {
            Logger.shared.verbose("授权根目录权限失败")
            return
        }
        self.saveBookmarkData(for: url, defaultKey: .rootDirectoryBookmark)
        Logger.shared.verbose("授权根目录权限成功-\(url.path)")
    }
    
    func cancelFullDiskPermissions() {
        Logger.shared.verbose("取消授权根目录权限")
        Defaults[.rootDirectoryBookmark] = nil
        Logger.shared.verbose("取消根目录权限成功")
    }
    
    func requestHomeDirectoryPermissions() {
        Logger.shared.verbose("开始授权主目录权限")
        guard let url = self.promptForWorkingDirectoryPermission(for: URL(fileURLWithPath: "~/", isDirectory: true)) else {
            Logger.shared.verbose("授权主目录权限失败")
            return
        }
        self.saveBookmarkData(for: url, defaultKey: .homeDirectoryBookmark)
        Logger.shared.verbose("授权主目录权限成功-\(url.path)")
    }
    
    // 获取安全授权，根目录授权优先获取，无根目录书签时获取主目录书签
    func startDirectoryAccessing() -> Bool {
        Logger.shared.verbose("开始获取安全授权")
        
        stopDirectoryAccessing()
        
        // 获取根目录授权书签
        if let data = Defaults[.rootDirectoryBookmark], let url = restoreFileAccess(with: data, defaultKey: .rootDirectoryBookmark) {
            
            workingDirectoryBookmarkUrl = url
            let flag = url.startAccessingSecurityScopedResource()
            Logger.shared.verbose("获取安全授权完成--根目录-\(url.path)")
            return flag
        } else if let data = Defaults[.homeDirectoryBookmark], let url = restoreFileAccess(with: data, defaultKey: .homeDirectoryBookmark) {
            // 获取主目录授权书签
            
            workingDirectoryBookmarkUrl = url
            let flag = url.startAccessingSecurityScopedResource()
            Logger.shared.verbose("获取安全授权完成--用户主目录-\(url.path)")
            return flag
        }
        Logger.shared.verbose("未获取安全授权")
        
        return false
    }
    
    func stopDirectoryAccessing() {
        Logger.shared.verbose("开始停止获取安全授权")
        guard let url = workingDirectoryBookmarkUrl else {
            Logger.shared.verbose("停止获取安全授权失败，未获取到书签")
            return
        }
        url.stopAccessingSecurityScopedResource()
        workingDirectoryBookmarkUrl = nil
        Logger.shared.verbose("停止获取安全授权完成")
    }
}
