# DiskPermissionManager 集成指南

## 概述

本文档说明了如何在 uPic v2 中集成和使用 `DiskPermissionManager` 来管理 macOS 的完全磁盘访问权限，以及优化后的上传器如何处理文件访问权限。

## DiskPermissionManager 核心功能

### 主要特性

- ✅ **智能权限检测**: 自动检测完全磁盘访问权限状态
- ✅ **多版本适配**: 支持 macOS 26.0+ 的根目录 bookmark bug 临时解决方案
- ✅ **权限管理**: 提供权限请求、检查和释放的完整生命周期管理
- ✅ **安全作用域**: 正确处理文件和目录的安全作用域资源访问
- ✅ **系统集成**: 直接打开系统偏好设置的权限页面

### 核心方法

```swift
public class DiskPermissionManager {
    public static var shared = DiskPermissionManager()

    // 检查权限状态
    func checkFullDiskAuthorizationStatus() -> Bool

    // 请求权限
    func requestFullDiskPermissions()

    // 启动权限访问
    func startDirectoryAccessing() -> Bool

    // 停止权限访问
    func stopDirectoryAccessing()

    // 打开系统偏好设置
    func openPreferences()
}
```

## 权限管理界面 (Permissions.swift)

### 功能特性

- **实时权限检测**: 界面加载时自动检查当前权限状态
- **一键权限请求**: 提供便捷的权限申请按钮
- **系统设置快捷方式**: 直接打开系统偏好设置
- **状态反馈**: 清晰的视觉反馈显示权限状态

### 代码示例

```swift
struct Permissions: View {
    @State private var hasFullDiskAccessPermission = false
    private let diskPermissionManager = DiskPermissionManager.shared

    private func checkPermissions() {
        hasFullDiskAccessPermission = diskPermissionManager.checkFullDiskAuthorizationStatus()
    }

    private func requestFullDiskAccess() {
        diskPermissionManager.requestFullDiskPermissions()

        // 延迟检查权限状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            checkPermissions()
        }
    }

    private func openSystemPreferences() {
        diskPermissionManager.openPreferences()
    }
}
```

## 优化后的上传器 (UPicUploader.swift)

### 主要改进

1. **集成权限管理**: 使用 `DiskPermissionManager` 管理磁盘访问权限
2. **智能权限处理**: 自动检查和启动权限访问
3. **安全作用域管理**: 正确处理文件级别的安全作用域
4. **错误处理增强**: 提供详细的权限相关错误信息

### 核心流程

```swift
public func upload(hostModel: HostModel, fileURLs: [URL]) async {
    let diskPermissionManager = DiskPermissionManager.shared

    // 1. 检查权限状态
    if !diskPermissionManager.checkFullDiskAuthorizationStatus() {
        // 2. 尝试启动已有权限
        guard diskPermissionManager.startDirectoryAccessing() else {
            // 3. 权限不足时提供错误信息
            await MainActor.run {
                self.onUploadFail?("缺少磁盘访问权限", "请在应用设置中授权完全磁盘访问权限")
            }
            return
        }
    }

    // 4. 处理文件上传
    for url in fileURLs {
        if let item = await safelyProcessFile(url: url) {
            // 上传处理
        }
    }

    // 5. 释放权限
    diskPermissionManager.stopDirectoryAccessing()
}
```

### 安全文件处理

```swift
private func safelyProcessFile(url: URL) async -> UploadItem? {
    // 1. 基本文件检查
    guard FileManager.default.fileExists(atPath: url.path),
          FileManager.default.isReadableFile(atPath: url.path) else {
        return nil
    }

    // 2. 尝试文件级别的安全作用域访问
    let hasFileScopedAccess = url.startAccessingSecurityScopedResource()

    defer {
        if hasFileScopedAccess {
            url.stopAccessingSecurityScopedResource()
        }
    }

    // 3. 安全读取文件数据
    do {
        let data = try Data(contentsOf: url)
        // 处理文件数据...
        return uploadItem
    } catch {
        return nil
    }
}
```

## 使用示例

### 基本集成

```swift
// 在应用中检查权限
let uploader = UPicUploader(modelContext: modelContext)

if uploader.checkDiskPermissions() {
    // 有权限，可以上传
    await uploader.upload(hostModel: host, fileURLs: fileURLs)
} else {
    // 无权限，请求权限
    uploader.requestDiskPermissions()
}
```

### 在 SwiftUI 中使用

```swift
struct UploadView: View {
    @StateObject private var uploader = UPicUploader(modelContext: modelContext)
    @State private var hasPermissions = false

    var body: some View {
        VStack {
            if hasPermissions {
                Button("Upload Files") {
                    // 执行上传
                }
            } else {
                Button("Request Permissions") {
                    uploader.requestDiskPermissions()
                }
            }
        }
        .onAppear {
            hasPermissions = uploader.checkDiskPermissions()
        }
    }
}
```

## 权限处理最佳实践

### 1. 权限检查时机

- **应用启动时**: 检查当前权限状态
- **文件访问前**: 确保有必要的访问权限
- **权限请求后**: 延迟检查权限状态更新

### 2. 错误处理

```swift
// 提供用户友好的错误信息
if !diskPermissionManager.startDirectoryAccessing() {
    await MainActor.run {
        self.onUploadFail?(
            "缺少磁盘访问权限",
            "请在应用设置 > 权限 中授权完全磁盘访问权限"
        )
    }
}
```

### 3. 资源管理

```swift
// 确保权限资源正确释放
defer {
    diskPermissionManager.stopDirectoryAccessing()
}
```

### 4. 用户体验

- **清晰的状态指示**: 显示当前权限状态
- **便捷的操作**: 提供一键权限申请
- **引导性提示**: 指导用户如何手动配置权限

## macOS 版本兼容性

### macOS 26.0 临时解决方案

```swift
// DiskPermissionManager 自动处理根目录 bookmark bug
if shouldUseRootSubdirectoryWorkaround() {
    // 使用子目录 bookmark 方案
    return checkRootSubdirectoriesAuthorizationStatus()
} else {
    // 使用传统的根目录 bookmark 方案
    return checkTraditionalBookmark()
}
```

### 版本检测

```swift
private func shouldUseRootSubdirectoryWorkaround() -> Bool {
    let osVersion = ProcessInfo.processInfo.operatingSystemVersion

    // macOS 26.0 需要使用临时解决方案
    if osVersion.majorVersion == 26 && osVersion.minorVersion == 0 {
        return true
    }

    return false
}
```

## 调试和日志

### 权限相关日志

```swift
AppLogger.uploader.verbose("[UPicUploader] 开始通过 URL 上传 -> \(fileURLs.count) 个文件")
AppLogger.uploader.warning("[UPicUploader] 缺少磁盘访问权限，尝试启动权限访问")
AppLogger.uploader.error("[UPicUploader] 无法获取磁盘访问权限，请在设置中授权")
```

### 权限状态检查

```swift
// 检查权限状态的详细日志
Logger.shared.verbose("开始检查是否有全盘访问权限")
Logger.shared.verbose("有全盘访问权限")
Logger.shared.verbose("没有全盘访问权限-书签已过期，需要保存一个新的...")
```

## 总结

通过集成 `DiskPermissionManager`，uPic v2 现在提供了：

1. **完整的权限管理**: 从检测到请求的完整权限生命周期管理
2. **智能的版本适配**: 自动处理不同 macOS 版本的权限问题
3. **用户友好的界面**: 清晰的权限状态和便捷的操作按钮
4. **安全的文件访问**: 正确处理安全作用域资源
5. **详细的错误处理**: 提供有用的错误信息和解决方案

这使得 uPic 能够在 macOS 的安全沙盒环境中可靠地访问和上传用户文件。