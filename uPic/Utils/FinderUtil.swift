//
//  FinderUtil.swift
//  uPic
//
//  Created by Svend Jin on 2020/3/7.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation

class FinderUtil {
    private static var groupName: String {
        let infoDic = Bundle.main.infoDictionary!
        return "\(infoDic["TeamIdentifierPrefix"]!)com.svend.uPic"
    }
    
    // MARK: - App Group Shared Files
    
    /// 获取 App Group 共享目录
    private static var sharedContainerURL: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)
    }
    
    /// 获取共享文件存储目录
    private static var sharedFilesDirectory: URL? {
        guard let containerURL = sharedContainerURL else { return nil }
        let filesDir = containerURL.appendingPathComponent("SharedFiles")
        
        // 确保目录存在
        if !FileManager.default.fileExists(atPath: filesDir.path) {
            try? FileManager.default.createDirectory(at: filesDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        return filesDir
    }
    
    /// 将文件复制到共享目录
    /// - Parameter fileURL: 原始文件URL
    /// - Returns: 共享目录中的文件URL，如果失败返回nil
    static func copyFileToSharedDirectory(_ fileURL: URL) -> URL? {
        guard let sharedDir = sharedFilesDirectory else { return nil }
        
        // 为每个文件创建一个独立的UUID目录
        let uniqueDir = sharedDir.appendingPathComponent(UUID().uuidString)
        let destinationURL = uniqueDir.appendingPathComponent(fileURL.lastPathComponent)
        
        do {
            // 创建独立目录
            try FileManager.default.createDirectory(at: uniqueDir, withIntermediateDirectories: true, attributes: nil)
            // 复制文件，保持原始文件名
            try FileManager.default.copyItem(at: fileURL, to: destinationURL)
            return destinationURL
        } catch {
            print("复制文件到共享目录失败: \(error)")
            return nil
        }
    }
    
    /// 从共享目录删除文件
    /// - Parameter fileURL: 要删除的文件URL
    static func removeFileFromSharedDirectory(_ fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("删除共享文件失败: \(error)")
        }
    }
    
    /// 清理所有共享文件
    static func cleanupSharedFiles() {
        guard let sharedDir = sharedFilesDirectory else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: sharedDir, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("清理共享文件失败: \(error)")
        }
    }
    
    // MARK: - Share Extension Communication
    
    private static let sharedFilesKey = "uPic_SharedFiles"
    
    /// 保存共享文件信息
    /// - Parameter fileURLs: 共享文件URL数组
    static func saveSharedFiles(_ fileURLs: [URL]) {
        let defaults = UserDefaults(suiteName: groupName)
        let filePaths = fileURLs.map { $0.path }
        defaults?.set(filePaths, forKey: sharedFilesKey)
        defaults?.synchronize()
    }
    
    /// 获取并清除共享文件信息
    /// - Returns: 共享文件URL数组
    static func getAndClearSharedFiles() -> [URL] {
        let defaults = UserDefaults(suiteName: groupName)
        guard let filePaths = defaults?.array(forKey: sharedFilesKey) as? [String] else {
            return []
        }
        
        // 清除数据
        defaults?.removeObject(forKey: sharedFilesKey)
        defaults?.synchronize()
        
        return filePaths.map { URL(fileURLWithPath: $0) }
    }
    
    /// 检查是否有待处理的共享文件
    /// - Returns: 是否有共享文件
    static func hasSharedFiles() -> Bool {
        let defaults = UserDefaults(suiteName: groupName)
        return defaults?.array(forKey: sharedFilesKey) != nil
    }
}
