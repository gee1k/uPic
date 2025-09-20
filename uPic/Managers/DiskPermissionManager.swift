//
//  DiskPermissionManager.swift
//  uPic
//
//  Created by Svend Jin on 2021/01/19.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa
import LCPermissionsKit

public class DiskPermissionManager {
    
    // static
    public static var shared = DiskPermissionManager()
    
    private init() {}
    
}

// Utils
extension DiskPermissionManager {
    
    /// 检查完全磁盘访问权限状态
    /// - Returns: 是否已授权完全磁盘访问权限
    func checkFullDiskAuthorizationStatus() -> Bool {
        Logger.shared.verbose("开始检查是否有全盘访问权限")
        let status = LCPermissionsKit.shared.authorizationStatus(for: .fullDiskAccess)
        let isAuthorized = (status == .authorized)
        Logger.shared.verbose(isAuthorized ? "有全盘访问权限" : "没有全盘访问权限")
        return isAuthorized
    }
    
    /// 请求完全磁盘访问权限
    func requestFullDiskPermissions() {
        Logger.shared.verbose("开始授权根目录权限")
        LCPermissionsKit.shared.requestAuthorization(for: .fullDiskAccess) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    Logger.shared.verbose("授权根目录权限成功")
                case .denied:
                    Logger.shared.verbose("授权根目录权限被拒绝")
                case .notDetermined:
                    Logger.shared.verbose("授权根目录权限未确定")
                case .limited:
                    Logger.shared.verbose("授权根目录权限有限")
                @unknown default:
                    Logger.shared.verbose("授权根目录权限状态未知")
                }
            }
        }
    }
    
    /// 打开系统偏好设置 - 完全磁盘访问权限
    func openPreferences() {
        // 使用工作区打开系统偏好设置中的完全磁盘访问权限设置页面
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
    }

    /// Workaround: 删除旧版本的根目录和用户目录权限
    /// 仅在应用启动时调用一次
    func removeOldFullDiskPermissions() {
        Defaults[.rootDirectoryBookmark] = nil
        Defaults[.homeDirectoryBookmark] = nil
    }
}
