//
//  BookmarkManager.swift
//  uPic
//
//  Created by Svend Jin on 2021/01/19.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa
import Defaults
import Foundation
import SimpleLogger

public class BookmarkManager {
    // static
    public static var shared = BookmarkManager()

    // 储存当前开始授权访问的 URL 对象
    private var workingDirectoryBookmarkUrl: URL?
    // 储存根目录子目录访问的 URL 对象列表
    private var rootSubdirectoryUrls: [URL] = []
    
    private init() {}
    
    // MARK: - macOS Version Detection
    
    /// 检测是否需要使用根目录 bookmark 的临时解决方案
    /// macOS 26.0 存在根目录 bookmark 创建失败的 bug，需要使用子目录 bookmark 的解决方案
    /// 该 bug 已在 macOS 26.1 beta 中修复
    private func shouldUseRootSubdirectoryWorkaround() -> Bool {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        
        // macOS 26.0 需要使用临时解决方案
        if osVersion.majorVersion == 26 && osVersion.minorVersion == 0 {
            return true
        }
        
        return false
    }
    
    // MARK: - Directory Permission Prompts
    
    private func promptForWorkingDirectoryPermission(for directoryURL: URL = URL(fileURLWithPath: "/", isDirectory: true)) -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.message = String(localized: "Authorize")
        openPanel.prompt = String(localized: "Authorize")
        openPanel.allowedContentTypes = []
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseDirectories = true
        openPanel.directoryURL = directoryURL
        
        openPanel.runModal()
        return openPanel.urls.first
    }
    
    private func saveBookmarkData(for workDir: URL, defaultKey: Defaults.Key<Data>) {
        do {
            let bookmarkData = try workDir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            
            // save in UserDefaults
            Defaults[defaultKey] = bookmarkData
        } catch {
            print("Failed to save bookmark data for \(workDir)", error)
        }
    }
    
    private func restoreRootDirectoryFileAccess(with bookmarkData: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                Defaults[.rootDirectoryBookmark] = bookmarkData
            }
            return url
        } catch {
            print("Error resolving bookmark:", error)
            return nil
        }
    }
    
    private func restoreHomeDirectoryFileAccess(with bookmarkData: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                Defaults[.homeDirectoryBookmark] = bookmarkData
            }
            return url
        } catch {
            print("Error resolving bookmark:", error)
            return nil
        }
    }
    
    // MARK: - Root Subdirectory Bookmark Methods (macOS 26.0 Workaround)
    
    /// 为根目录的所有子目录创建 security-scoped bookmark (macOS 26.0 临时解决方案)
    private func createRootSubdirectoryBookmarks(rootURL: URL) -> Bool {
        AppLogger.bookmark.info("开始为根目录子目录创建书签")
        
        // 通常无法创建 bookmark 的系统目录和文件
        let excludedPaths: Set<String> = [
            "home", "dev", "tmp", "var", "etc", "private",
            ".file", ".VolumeIcon.icns", ".fseventsd", ".DocumentRevisions-V100",
            ".Spotlight-V100", ".Trashes", ".vol", "net"
        ]
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: rootURL, includingPropertiesForKeys: [.isDirectoryKey], options: [])
            var bookmarkDataArray: [Data] = []
            var subdirectoryNames: [String] = []
            var successCount = 0
            var failureCount = 0
            
            // 重要目录优先处理
            let priorityDirs = ["Applications", "System", "Users", "Library", "Volumes"]
            let allContents = contents.sorted { url1, url2 in
                let name1 = url1.lastPathComponent
                let name2 = url2.lastPathComponent
                let priority1 = priorityDirs.firstIndex(of: name1) ?? Int.max
                let priority2 = priorityDirs.firstIndex(of: name2) ?? Int.max
                return priority1 < priority2
            }
            
            for url in allContents {
                let fileName = url.lastPathComponent
                
                // 跳过已知的系统目录和隐藏文件
                if excludedPaths.contains(fileName) {
                    AppLogger.bookmark.info("跳过系统目录: \(url.path)")
                    continue
                }
                
                // 跳过以点开头的隐藏文件/目录（除了一些重要的目录）
                if fileName.hasPrefix(".") && !priorityDirs.contains(fileName) {
                    AppLogger.bookmark.info("跳过隐藏项目: \(url.path)")
                    continue
                }
                
                do {
                    let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                    bookmarkDataArray.append(bookmarkData)
                    subdirectoryNames.append(fileName)
                    successCount += 1
                    AppLogger.bookmark.info("成功创建子目录书签: \(url.path)")
                } catch {
                    failureCount += 1
                    AppLogger.bookmark.info("为子目录创建书签失败: \(url.path), 错误: \(error.localizedDescription)")
                    // 继续处理其他目录，不因为单个目录失败而终止
                }
            }
            
            // 保存到 UserDefaults
            Defaults[.rootSubdirectoryBookmarks] = bookmarkDataArray
            Defaults[.rootSubdirectoryNames] = subdirectoryNames
            
            AppLogger.bookmark.info("根目录子目录书签创建完成，成功: \(successCount), 失败: \(failureCount), 总共有效书签: \(bookmarkDataArray.count)")
            
            // 只要有一些成功的书签就认为是成功的
            return bookmarkDataArray.count >= 2 // 至少需要2个有效书签才算成功
            
        } catch {
            AppLogger.bookmark.error("读取根目录内容失败: \(error)")
            return false
        }
    }
    
    /// 检查根目录子目录权限状态（macOS 26.0 临时解决方案）
    private func checkRootSubdirectoriesAuthorizationStatus() -> Bool {
        AppLogger.bookmark.info("开始检查根目录子目录权限状态")
        let storedNames = Defaults[.rootSubdirectoryNames]
        let bookmarkDataArray = Defaults[.rootSubdirectoryBookmarks]
        
        guard !bookmarkDataArray.isEmpty else {
            AppLogger.bookmark.info("未找到根目录子目录书签")
            return false
        }
        
        // 检查存储的书签数量是否合理
        if bookmarkDataArray.count < 2 {
            AppLogger.bookmark.info("有效书签数量太少，需要重新授权")
            return false
        }
        
        // 检查重要目录的书签是否存在（这些是最常用的目录）
        let importantDirs = ["Applications", "System", "Users", "Library", "Volumes"]
        let hasImportantDirs = importantDirs.contains { importantDir in
            storedNames.contains(importantDir)
        }
        
        if !hasImportantDirs {
            AppLogger.bookmark.info("缺少重要目录的书签，权限可能不完整")
            return false
        }
        
        // 尝试解析一些关键的 bookmark 来验证它们仍然有效
        var validBookmarks = 0
        for (index, bookmarkData) in bookmarkDataArray.enumerated() {
            if index >= storedNames.count { break }
            
            do {
                var isStale = false
                _ = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                if !isStale {
                    validBookmarks += 1
                }
            } catch {
                AppLogger.bookmark.info("书签解析失败: \(storedNames[index])")
            }
        }
        
        // 如果大部分书签都有效，认为权限状态良好
        let validRatio = Double(validBookmarks) / Double(bookmarkDataArray.count)
        let hasValidPermissions = validRatio > 0.6 // 60% 的书签有效就认为权限正常（考虑到某些目录可能会变化）
        
        AppLogger.bookmark.info("根目录子目录权限检查完成，有效书签: \(validBookmarks)/\(bookmarkDataArray.count)，比例: \(validRatio)")
        return hasValidPermissions
    }
    
    /// 启动根目录子目录访问（macOS 26.0 临时解决方案）
    private func startRootSubdirectoriesAccessing() -> Bool {
        AppLogger.bookmark.info("开始启动根目录子目录访问")
        let bookmarkDataArray = Defaults[.rootSubdirectoryBookmarks]
        let storedNames = Defaults[.rootSubdirectoryNames]
        
        guard !bookmarkDataArray.isEmpty else {
            AppLogger.bookmark.info("未找到根目录子目录书签")
            return false
        }
        
        // 停止之前的访问
        stopRootSubdirectoriesAccessing()
        
        var successCount = 0
        var failureCount = 0
        rootSubdirectoryUrls.removeAll()
        
        for (index, bookmarkData) in bookmarkDataArray.enumerated() {
            let dirName = index < storedNames.count ? storedNames[index] : "未知目录"
            
            do {
                var isStale = false
                let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                
                if isStale {
                    AppLogger.bookmark.info("书签已过期: \(dirName)")
                    failureCount += 1
                    continue
                }
                
                if url.startAccessingSecurityScopedResource() {
                    rootSubdirectoryUrls.append(url)
                    successCount += 1
                    AppLogger.bookmark.info("成功启动访问: \(url.path)")
                } else {
                    AppLogger.bookmark.info("启动安全作用域访问失败: \(url.path)")
                    failureCount += 1
                }
                
            } catch {
                AppLogger.bookmark.info("解析书签失败 (\(dirName)): \(error.localizedDescription)")
                failureCount += 1
            }
        }
        
        // 只要有一些成功的访问就认为成功
        let success = successCount >= 2 // 至少需要2个成功的访问
        AppLogger.bookmark.info("根目录子目录访问启动完成，成功: \(successCount), 失败: \(failureCount)")
        
        if !success {
            // 如果失败，清理已启动的访问
            stopRootSubdirectoriesAccessing()
        }
        
        return success
    }
    
    /// 停止根目录子目录访问（macOS 26.0 临时解决方案）
    private func stopRootSubdirectoriesAccessing() {
        AppLogger.bookmark.info("开始停止根目录子目录访问")
        
        for url in rootSubdirectoryUrls {
            url.stopAccessingSecurityScopedResource()
        }
        rootSubdirectoryUrls.removeAll()
        
        AppLogger.bookmark.info("根目录子目录访问停止完成")
    }
}

// Utils
extension BookmarkManager {
    /// 检查完全磁盘访问权限状态
    /// - Returns: 是否已授权完全磁盘访问权限
    func checkFullDiskAuthorizationStatus() -> Bool {
        AppLogger.bookmark.info("开始检查是否有全盘访问权限")
        
        // 如果需要使用临时解决方案（macOS 26.0）
        if shouldUseRootSubdirectoryWorkaround() {
            AppLogger.bookmark.info("使用根目录子目录权限检查方案 (macOS 26.0 临时解决方案)")
            return checkRootSubdirectoriesAuthorizationStatus()
        }
        
        // 传统的根目录 bookmark 检查方案
        if let data = Defaults[.rootDirectoryBookmark] {
            do {
                var isStale = true
                let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                if isStale {
                    // bookmarks could become stale as the OS changes
                    print("Bookmark is stale, need to save a new one... ")
                    AppLogger.bookmark.info("没有全盘访问权限-书签已过期，需要保存一个新的...")
                } else if url.path == "/" {
                    AppLogger.bookmark.info("有全盘访问权限")
                    return true
                } else {
                    AppLogger.bookmark.info("没有全盘访问权限-书签路径为\(url.path)")
                }
            } catch {
                print("Error resolving bookmark:", error)
                AppLogger.bookmark.error("没有全盘访问权限-书签错误\(error)")
            }
        } else {
            AppLogger.bookmark.info("没有全盘访问权限-未找到传统根目录书签")
        }
        
        // 如果传统方案失败，检查是否有子目录 bookmarks 作为回退方案
        if !Defaults[.rootSubdirectoryBookmarks].isEmpty {
            AppLogger.bookmark.info("传统根目录方案失败，尝试检查子目录权限方案")
            return checkRootSubdirectoriesAuthorizationStatus()
        }
        
        AppLogger.bookmark.info("没有找到任何有效的磁盘访问权限")
        return false
    }
    
    // MARK: - Private Common Permission Request Method
    
    /// 通用的权限请求处理方法
    /// - Parameter defaultDirectory: 默认打开的目录路径
    private func requestDirectoryPermissions(defaultDirectory: String) {
        let logPrefix = defaultDirectory == "/" ? "根目录" : "主目录"
        AppLogger.bookmark.info("开始授权\(logPrefix)权限")
        
        guard let url = promptForWorkingDirectoryPermission(for: URL(fileURLWithPath: defaultDirectory, isDirectory: true)) else {
            AppLogger.bookmark.info("授权\(logPrefix)权限失败")
            return
        }
        
        // 检查用户实际选择的路径
        if url.path == "/" {
            // 用户选择了根目录，按全盘权限处理
            AppLogger.bookmark.info("用户选择了根目录，按全盘权限处理")
            
            // 如果需要使用临时解决方案（macOS 26.0）
            if shouldUseRootSubdirectoryWorkaround() {
                AppLogger.bookmark.info("使用根目录子目录权限授权方案 (macOS 26.0 临时解决方案)")
                if createRootSubdirectoryBookmarks(rootURL: url) {
                    AppLogger.bookmark.info("根目录子目录权限授权成功")
                } else {
                    AppLogger.bookmark.info("根目录子目录权限授权失败")
                }
                return
            }
            
            // 传统的根目录 bookmark 方案
            do {
                let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                // 如果成功，保存为根目录 bookmark
                Defaults[.rootDirectoryBookmark] = bookmarkData
                AppLogger.bookmark.info("保存为全盘权限-\(url.path)")
            } catch {
                AppLogger.bookmark.error("创建根目录 bookmark 失败: \(error)")
                
                // 如果传统方案失败，尝试使用临时解决方案
                AppLogger.bookmark.info("根目录 bookmark 创建失败，尝试使用子目录方案")
                if createRootSubdirectoryBookmarks(rootURL: url) {
                    AppLogger.bookmark.info("fallback 到根目录子目录权限授权成功")
                } else {
                    AppLogger.bookmark.info("fallback 到根目录子目录权限授权也失败")
                }
            }
        } else {
            let bookmarkData = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            // 用户选择的是其他目录，按主目录权限处理
            Defaults[.homeDirectoryBookmark] = bookmarkData
            AppLogger.bookmark.info("授权主目录权限成功-\(url.path)")
        }
    }
    
    // MARK: - Public Permission Request Methods
    
    /// 请求完全磁盘访问权限（默认打开根目录）
    func requestFullDiskPermissions() {
        requestDirectoryPermissions(defaultDirectory: "/")
    }
    
    /// 请求主目录访问权限（默认打开用户主目录，但支持用户手动切换到根目录）
    func requestHomeDirectoryPermissions() {
        requestDirectoryPermissions(defaultDirectory: "~/")
    }
    
    func cancelFullDiskPermissions() {
        AppLogger.bookmark.info("取消授权根目录权限")
        
        // 清除传统的根目录 bookmark
        Defaults[.rootDirectoryBookmark] = nil
        
        // 清除临时解决方案的子目录 bookmarks
        Defaults[.rootSubdirectoryBookmarks] = []
        Defaults[.rootSubdirectoryNames] = []
        
        // 停止当前的访问
        stopDirectoryAccessing()
        
        AppLogger.bookmark.info("取消根目录权限成功")
    }
    
    // 获取安全授权，根目录授权优先获取，无根目录书签时获取主目录书签
    func startDirectoryAccessing() -> Bool {
        AppLogger.bookmark.info("开始获取安全授权")
        
        stopDirectoryAccessing()
        
        // 如果需要使用临时解决方案（macOS 26.0）并且有子目录 bookmarks
        if shouldUseRootSubdirectoryWorkaround() {
            if !Defaults[.rootSubdirectoryBookmarks].isEmpty {
                AppLogger.bookmark.info("使用根目录子目录访问方案 (macOS 26.0 临时解决方案)")
                let success = startRootSubdirectoriesAccessing()
                if success {
                    AppLogger.bookmark.info("获取安全授权完成--根目录子目录方案")
                    return true
                }
                AppLogger.bookmark.info("根目录子目录方案失败，尝试其他方案")
            }
        }
        
        // 获取根目录授权书签（传统方案或 macOS 26.1+ 修复后的方案）
        if let data = Defaults[.rootDirectoryBookmark], let url = restoreRootDirectoryFileAccess(with: data) {
            workingDirectoryBookmarkUrl = url
            let flag = url.startAccessingSecurityScopedResource()
            AppLogger.bookmark.info("获取安全授权完成--根目录-\(url.path)")
            return flag
        }
        
        // 如果根目录方案都失败，尝试主目录授权书签
        if let data = Defaults[.homeDirectoryBookmark], let url = restoreHomeDirectoryFileAccess(with: data) {
            workingDirectoryBookmarkUrl = url
            let flag = url.startAccessingSecurityScopedResource()
            AppLogger.bookmark.info("获取安全授权完成--用户主目录-\(url.path)")
            return flag
        }
        
        AppLogger.bookmark.info("未获取安全授权")
        return false
    }
    
    func stopDirectoryAccessing() {
        AppLogger.bookmark.info("开始停止获取安全授权")
        
        // 停止根目录子目录访问
        stopRootSubdirectoriesAccessing()
        
        // 停止传统的单一目录访问
        if let url = workingDirectoryBookmarkUrl {
            url.stopAccessingSecurityScopedResource()
            workingDirectoryBookmarkUrl = nil
        }
        
        AppLogger.bookmark.info("停止获取安全授权完成")
    }
    
    /// 打开系统偏好设置 - 完全磁盘访问权限
    func openPreferences() {
        // 使用工作区打开系统偏好设置中的完全磁盘访问权限设置页面
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
    }

    /// 尝试从子目录方案升级到根目录方案（当系统修复 bug 后）
    /// 在应用启动时调用，检查是否可以升级到更好的方案
    func tryUpgradeToRootDirectoryPermission() {
        AppLogger.bookmark.info("检查是否可以升级到根目录权限方案")
        
        // 如果当前系统不需要使用临时解决方案，但我们有子目录 bookmarks
        if !shouldUseRootSubdirectoryWorkaround() {
            if !Defaults[.rootSubdirectoryBookmarks].isEmpty, Defaults[.rootDirectoryBookmark] == nil {
                AppLogger.bookmark.info("系统已修复根目录 bookmark bug，但当前使用子目录方案，尝试升级")
                
                // 尝试创建根目录 bookmark 来测试是否已修复
                let testURL = URL(fileURLWithPath: "/", isDirectory: true)
                do {
                    _ = try testURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                    AppLogger.bookmark.info("根目录 bookmark 创建测试成功，系统已修复 bug")
                    
                    // 注意：这里不能自动升级，因为需要用户重新授权
                    // 只是清除临时方案的数据，提示用户重新授权会使用更好的方案
                    AppLogger.bookmark.info("清除临时方案数据，等待用户重新授权")
                    Defaults[.rootSubdirectoryBookmarks] = []
                    Defaults[.rootSubdirectoryNames] = []
                    
                } catch {
                    AppLogger.bookmark.info("根目录 bookmark 创建测试失败，系统尚未修复: \(error)")
                }
            }
        }
    }
}
