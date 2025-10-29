//
//  UPicUploader.swift
//  uPic
//
//  Created by Licardo on 2025/10/29.
//

import AppKit
import Combine
import Defaults
import Foundation
import SimpleLogger
import SwiftData
import SwiftUI
import UPicCore
import UniformTypeIdentifiers

public struct UploadItem {
    var data: Data?
    var thumbnailData: Data?
    var pixelWidth: Int = 0
    var pixelHeight: Int = 0
    var originalFilename: String?
}

@MainActor
public class UPicUploader: ObservableObject {
    // MARK: - Shared Instance
    public static let shared = UPicUploader()

    // MARK: - Published Properties

    @Published var isUploading = false
    @Published var uploadProgress: Double = 0.0
    @Published var currentUploadingItem: Data? = nil
    @Published var uploadHistory: [UploadHistoryModel] = []

    // MARK: - Dependencies

    private let modelContext: ModelContext
    private let notificationCenter = NotificationCenter.default

    // MARK: - Callbacks

    public var onUploadStart: (() -> Void)?
    public var onUploadComplete: ((String) -> Void)?
    public var onUploadFail: ((String, String?) -> Void)?
    public var onAllUploadsComplete: (() -> Void)?

    // MARK: - Initialization

    private init() {
        let context = ModelContext(try! ModelContainer(for: HostModel.self, UploadHistoryModel.self))
        self.modelContext = context
        loadUploadHistory()
    }

    // Public initializer for external use
    public convenience init(modelContext: ModelContext) {
        self.init()
        // Note: This will use the shared instance's modelContext
    }

    // MARK: - Permission Management

    /// 检查是否有磁盘访问权限
    public func checkDiskPermissions() -> Bool {
        return BookmarkManager.shared.checkFullDiskAuthorizationStatus()
    }

    /// 请求磁盘访问权限
    public func requestDiskPermissions() {
        BookmarkManager.shared.requestFullDiskPermissions()
    }

    /// 打开系统偏好设置
    public func openSystemPreferences() {
        BookmarkManager.shared.openPreferences()
    }
    
    public func cancelAllUploads() {
        UPicCore.shared.cancel()
    }

    // MARK: - Public Methods

    /// 通过文件URL上传
    public func upload(fileURLs: [URL]) async {
        guard let host = getSelectedHost() else {
            AppLogger.uploader.error("[UPicUploader] 没有可用的图床配置")
            await MainActor.run {
                self.onUploadFail?("没有可用的图床配置", nil)
            }
            return
        }

        await upload(hostModel: host, fileURLs: fileURLs)
    }

    /// 通过文件URL上传
    public func upload(hostModel: HostModel, fileURLs: [URL]) async {
        AppLogger.uploader.info("[UPicUploader] 开始通过 URL 上传 -> \(fileURLs.count) 个文件")

        // 使用 DiskPermissionManager 管理磁盘访问权限
        let diskPermissionManager = BookmarkManager.shared

        // 首先检查是否已有磁盘访问权限
        if !diskPermissionManager.checkFullDiskAuthorizationStatus() {
            AppLogger.uploader.warning("[UPicUploader] 缺少磁盘访问权限，尝试启动权限访问")

            // 尝试启动已有的权限访问
            guard diskPermissionManager.startDirectoryAccessing() else {
                AppLogger.uploader.error("[UPicUploader] 无法获取磁盘访问权限，请在设置中授权")
                await MainActor.run {
                    self.onUploadFail?("缺少磁盘访问权限", "请在应用设置中授权完全磁盘访问权限")
                }
                return
            }
        }

        var items: [UploadItem] = []
        var processedURLs: [URL] = []

        // 处理所有文件
        for url in fileURLs {
            AppLogger.uploader.info("[UPicUploader] 处理文件 -> \(url.path)")

            if let item = await safelyProcessFile(url: url) {
                items.append(item)
                processedURLs.append(url)
            }
        }

        // 执行上传
        await upload(hostModel: hostModel, items: items)

        // 释放磁盘访问权限
        diskPermissionManager.stopDirectoryAccessing()

        AppLogger.uploader.info("[UPicUploader] 磁盘访问权限已释放")
    }

    /// 安全地处理单个文件，使用 DiskPermissionManager
    private func safelyProcessFile(url: URL) async -> UploadItem? {
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: url.path) else {
            AppLogger.uploader.warning("[UPicUploader] 文件不存在 -> \(url.path)")
            return nil
        }

        // 检查文件是否可读
        guard FileManager.default.isReadableFile(atPath: url.path) else {
            AppLogger.uploader.warning("[UPicUploader] 文件不可读 -> \(url.path)")
            return nil
        }

        // 尝试使用文件自身的安全作用域（如果有）
        let hasFileScopedAccess = url.startAccessingSecurityScopedResource()

        do {
            let data = try Data(contentsOf: url)
            AppLogger.uploader.info("[UPicUploader] 成功读取文件数据 -> \(url.path), 大小: \(data.count) bytes")

            // 验证数据不为空
            guard !data.isEmpty else {
                AppLogger.uploader.warning("[UPicUploader] 文件数据为空 -> \(url.path)")
                if hasFileScopedAccess {
                    url.stopAccessingSecurityScopedResource()
                }
                return nil
            }

            var uploadItem = UploadItem()
            uploadItem.originalFilename = url.lastPathComponent
            uploadItem.data = data

            // 尝试解析图片信息
            if let image = NSImage(data: data) {
                uploadItem.pixelWidth = Int(image.size.width)
                uploadItem.pixelHeight = Int(image.size.height)

                // 生成缩略图
                let thumbnailData = generateThumbnail(from: image, quality: 0.3)
                uploadItem.thumbnailData = thumbnailData

                AppLogger.uploader.info("[UPicUploader] 图片信息 -> 尺寸: \(uploadItem.pixelWidth)×\(uploadItem.pixelHeight)")
            } else {
                AppLogger.uploader.info("[UPicUploader] 非图片文件 -> \(url.path)")
                // 对于非图片文件，仍然允许上传
                uploadItem.pixelWidth = 0
                uploadItem.pixelHeight = 0
                uploadItem.thumbnailData = data
            }

            // 如果使用了文件级别的安全作用域，在这里释放
            if hasFileScopedAccess {
                url.stopAccessingSecurityScopedResource()
            }

            return uploadItem

        } catch {
            AppLogger.uploader.error("[UPicUploader] 读取文件数据失败 -> \(url.path), 错误: \(error.localizedDescription)")

            // 出错时立即释放文件级别的安全作用域
            if hasFileScopedAccess {
                url.stopAccessingSecurityScopedResource()
            }
            return nil
        }
    }

    /// 通过Data上传
    public func upload(fileData: Data, filename: String? = nil) async {
        guard let host = getSelectedHost() else {
            AppLogger.uploader.error("[UPicUploader] 没有可用的图床配置")
            await MainActor.run {
                self.onUploadFail?("没有可用的图床配置", nil)
            }
            return
        }

        await upload(hostModel: host, fileData: fileData, filename: filename)
    }

    /// 通过Data上传
    public func upload(hostModel: HostModel, fileData: Data, filename: String? = nil) async {
        AppLogger.uploader.info("[UPicUploader] 开始通过 Data 上传")

        let image = NSImage(data: fileData)
        var uploadItem = UploadItem()
        uploadItem.originalFilename = filename ?? "upload_\(Date().timeIntervalSince1970)"
        uploadItem.pixelWidth = Int(image?.size.width ?? 0)
        uploadItem.pixelHeight = Int(image?.size.height ?? 0)
        uploadItem.data = fileData

        let thumbnailData = generateThumbnail(from: image, quality: 0.3)
        uploadItem.thumbnailData = thumbnailData

        await upload(hostModel: hostModel, items: [uploadItem])
    }

    /// 通过NSImage上传
    public func upload(images: [NSImage]) async {
        guard let host = getSelectedHost() else {
            AppLogger.uploader.error("[UPicUploader] 没有可用的图床配置")
            await MainActor.run {
                self.onUploadFail?("没有可用的图床配置", nil)
            }
            return
        }

        await upload(hostModel: host, images: images)
    }

    /// 通过NSImage上传
    public func upload(hostModel: HostModel, images: [NSImage]) async {
        AppLogger.uploader.info("[UPicUploader] 开始通过 NSImage 上传 -> \(images.count) 个图片")

        var items: [UploadItem] = []

        for (index, image) in images.enumerated() {
            var uploadItem = UploadItem()
            uploadItem.originalFilename = "image_\(index + 1).png"
            uploadItem.pixelWidth = Int(image.size.width)
            uploadItem.pixelHeight = Int(image.size.height)

            if let tiffData = image.tiffRepresentation,
               let bitmapRep = NSBitmapImageRep(data: tiffData),
               let pngData = bitmapRep.representation(using: .png, properties: [:])
            {
                uploadItem.data = pngData
            }

            uploadItem.thumbnailData = generateThumbnail(from: image, quality: 0.3)

            items.append(uploadItem)
        }

        await upload(hostModel: hostModel, items: items)
    }

    // MARK: - Private Methods

    private func upload(hostModel: HostModel, items: [UploadItem]) async {
        guard !items.isEmpty else {
            AppLogger.uploader.warning("[UPicUploader] 没有有效的上传项目")
            onAllUploadsComplete?()
            return
        }

        await MainActor.run {
            self.isUploading = true
            self.uploadProgress = 0.0
            self.onUploadStart?()
        }

        AppLogger.uploader.info("[UPicUploader] 开始执行上传任务队列 -> \(items.count)个")

        var successCount = 0
        let totalCount = items.count

        for (index, item) in items.enumerated() {
            guard let data = item.data else {
                AppLogger.uploader.warning("[UPicUploader] 跳过无数据的上传项目")
                continue
            }

            await MainActor.run {
                self.currentUploadingItem = item.thumbnailData ?? data
                self.uploadProgress = 0.0 // 每个文件开始时重置进度
            }

            let size = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .decimal)
            AppLogger.uploader.info("[UPicUploader] 上传进度 -> \(index + 1)/\(totalCount) - 文件大小 -> \(size)")

            do {
                let url = try await performSingleUpload(hostModel: hostModel, item: item)
                AppLogger.uploader.info("[UPicUploader] 上传成功 -> \(url)")

                await saveToHistory(item: item, url: url, hostId: hostModel.id)
                successCount += 1

                await MainActor.run {
                    self.onUploadComplete?(url)
                }

            } catch {
                let errorMessage = error.localizedDescription
                AppLogger.uploader.error("[UPicUploader] 上传失败 -> \(errorMessage)")

                await MainActor.run {
                    self.onUploadFail?(errorMessage, error.localizedDescription)
                }
            }
        }

        await MainActor.run {
            self.isUploading = false
            self.uploadProgress = 1.0
            self.currentUploadingItem = nil

            self.onAllUploadsComplete?()
        }

        AppLogger.uploader.info("[UPicUploader] 上传任务队列结束 -> 成功: \(successCount)/\(totalCount)")
    }

    private func performSingleUpload(hostModel: HostModel, item: UploadItem) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            UPicCore.shared
                .progress { progress in
                    Task { @MainActor in
                        self.uploadProgress = progress
                        AppLogger.uploader.info("[UPicUploader] 单文件上传进度: \(progress * 100)%")
                    }
                }
                .complete { url in
                    AppLogger.uploader.info("[UPicUploader] 单文件上传完成: \(url)")
                    continuation.resume(returning: url)
                }
                .fail { errorMessage, detailError in
                    let error = NSError(domain: "UploadError", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: errorMessage,
                        NSLocalizedFailureReasonErrorKey: detailError ?? ""
                    ])
                    continuation.resume(throwing: error)
                }
                .upload(hostModel: hostModel, fileData: item.data!, filename: item.originalFilename)
        }
    }

    private func saveToHistory(item: UploadItem, url: String, hostId: String?) async {
        await MainActor.run {
            let history = UploadHistoryModel(
                url: url,
                thumbnailData: item.thumbnailData,
                createdDate: Date(),
                size: item.data?.count ?? 0,
                pixelWidth: item.pixelWidth,
                pixelHeight: item.pixelHeight,
                originalFilename: item.originalFilename,
                hostId: hostId
            )

            modelContext.insert(history)

            do {
                try modelContext.save()
                AppLogger.uploader.info("[UPicUploader] 历史记录保存成功 -> \(url)")

                // 重新加载历史记录
                loadUploadHistory()

            } catch {
                AppLogger.uploader.error("[UPicUploader] 历史记录保存失败 -> \(error.localizedDescription)")
            }
        }
    }

    private func generateThumbnail(from image: NSImage?, quality: CGFloat) -> Data? {
        guard let image = image,
              let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData)
        else {
            return nil
        }

        return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: quality])
    }

    private func loadUploadHistory() {
        let descriptor = FetchDescriptor<UploadHistoryModel>(sortBy: [SortDescriptor(\.createdDate, order: .reverse)])

        do {
            uploadHistory = try modelContext.fetch(descriptor)
        } catch {
            AppLogger.uploader.error("[UPicUploader] 加载历史记录失败 -> \(error.localizedDescription)")
        }
    }

    // MARK: - Public History Management

    public func deleteHistory(_ history: UploadHistoryModel) {
        modelContext.delete(history)

        do {
            try modelContext.save()
            loadUploadHistory()
        } catch {
            AppLogger.uploader.error("[UPicUploader] 删除历史记录失败 -> \(error.localizedDescription)")
        }
    }

    public func clearAllHistory() {
        let descriptor = FetchDescriptor<UploadHistoryModel>()

        do {
            let histories = try modelContext.fetch(descriptor)
            for history in histories {
                modelContext.delete(history)
            }
            try modelContext.save()
            loadUploadHistory()
        } catch {
            AppLogger.uploader.error("[UPicUploader] 清空历史记录失败 -> \(error.localizedDescription)")
        }
    }

    // MARK: - File Selection Upload

    /// 选择文件上传
    public func uploadFromSelectFile() {
        AppLogger.uploader.info("[UPicUploader] 开始选择文件上传")

        if isUploading {
            AppLogger.uploader.warning("[UPicUploader] 当前上传任务未结束")
            return
        }

        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedContentTypes = [.image]

        openPanel.begin { [weak self] result in
            openPanel.close()
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                AppLogger.uploader.info("[UPicUploader] 选择文件数量：\(openPanel.urls.count)")
                Task {
                    await self?.upload(fileURLs: openPanel.urls)
                }
            }
        }

        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Clipboard Upload

    /// 从剪贴板上传
    public func uploadFromClipboard() {
        AppLogger.uploader.info("[UPicUploader] 开始从剪贴板上传")

        if isUploading {
            AppLogger.uploader.warning("[UPicUploader] 当前上传任务未结束")
            return
        }

        let pasteboard = NSPasteboard.general
        AppLogger.uploader.info("[UPicUploader] 剪贴板格式：\(pasteboard.types?.first?.rawValue ?? "未知")")

        // 检查文件
        if let filenames = pasteboard.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] {
            var urls = [URL]()

            for path in filenames {
                let url = URL(fileURLWithPath: path)
                let fileExtension = url.pathExtension.lowercased()
                if isImageFileExtension(fileExtension) {
                    urls.append(url)
                }
            }

            AppLogger.uploader.info("[UPicUploader] 剪贴板文件数量：\(urls.count)")

            if !urls.isEmpty {
                Task {
                    await upload(fileURLs: urls)
                }
                return
            }
        }

        // 检查图片数据
        let imageTypes: [NSPasteboard.PasteboardType] = [.png, .tiff]

        for imageType in imageTypes {
            if let imageData = pasteboard.data(forType: imageType) {
                AppLogger.uploader.info("[UPicUploader] 剪贴板上传图片：\(imageType.rawValue)")

                var processedData = imageData

                // 转换TIFF为JPEG
                if imageType == .tiff,
                   let image = NSImage(data: imageData),
                   let jpegData = image.jpegData(compressionQuality: 0.9) {
                    processedData = jpegData
                }

                Task {
                    await upload(fileData: processedData, filename: "clipboard_\(Date().timeIntervalSince1970).png")
                }
                return
            }
        }

        // 检查URL字符串
        if let urlString = pasteboard.string(forType: .string),
           let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) {
            AppLogger.uploader.info("[UPicUploader] 剪贴板上传URL：\(urlString)")

            Task {
                do {
                    let data = try Data(contentsOf: url)
                    if let selectedHost = getSelectedHost() {
                        await upload(hostModel: selectedHost, fileData: data, filename: url.lastPathComponent)
                    }
                } catch {
                    AppLogger.uploader.error("[UPicUploader] 从URL加载数据失败：\(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Screenshot Upload

    /// 截图上传
    public func uploadFromScreenshot() {
        AppLogger.uploader.info("[UPicUploader] 开始截图上传")

        if isUploading {
            AppLogger.uploader.warning("[UPicUploader] 当前上传任务未结束")
            return
        }

        // 检查屏幕录制权限
        if !checkScreenRecordingPermission() {
            AppLogger.uploader.warning("[UPicUploader] 无截图权限，申请权限")
            requestScreenRecordingPermission()
            return
        }

        // 使用系统截图工具
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-c"] // 交互模式，复制到剪贴板
        task.launch()
        task.waitUntilExit()

        // 检查剪贴板中的截图
        let pasteboard = NSPasteboard.general
        AppLogger.uploader.info("[UPicUploader] 截图格式：\(pasteboard.types?.first?.rawValue ?? "未知")")

        let imageTypes: [NSPasteboard.PasteboardType] = [.png, .tiff]

        for imageType in imageTypes {
            if let imageData = pasteboard.data(forType: imageType) {
                AppLogger.uploader.info("[UPicUploader] 截图上传成功：\(imageType.rawValue)")

                Task {
                    await upload(fileData: imageData, filename: "screenshot_\(Date().timeIntervalSince1970).png")
                }
                return
            }
        }

        AppLogger.uploader.warning("[UPicUploader] 截图失败或未找到图片数据")
    }

    // MARK: - Helper Methods

    /// 获取选中的图床配置
    private func getSelectedHost() -> HostModel? {
        guard let selectedHostId = Defaults[.selectedHostId] else {
            AppLogger.uploader.warning("[UPicUploader] 未选中任何图床配置")
            return getFirstHostAsFallback()
        }

        let descriptor = FetchDescriptor<HostModel>(
            predicate: #Predicate { $0.id == selectedHostId }
        )

        do {
            let hosts = try modelContext.fetch(descriptor)
            if let selectedHost = hosts.first {
                AppLogger.uploader.info("[UPicUploader] 使用选中的图床配置：\(selectedHost.name)")
                return selectedHost
            } else {
                AppLogger.uploader.warning("[UPicUploader] 选中的图床配置不存在，ID：\(selectedHostId)")
                return getFirstHostAsFallback()
            }
        } catch {
            AppLogger.uploader.error("[UPicUploader] 获取选中图床配置失败：\(error.localizedDescription)")
            return getFirstHostAsFallback()
        }
    }

    /// 获取第一个图床配置作为备用选项
    private func getFirstHostAsFallback() -> HostModel? {
        let descriptor = FetchDescriptor<HostModel>()
        do {
            let hosts = try modelContext.fetch(descriptor)
            if let firstHost = hosts.first {
                AppLogger.uploader.info("[UPicUploader] 使用第一个图床配置作为备用：\(firstHost.name)")
                // 自动设置为选中的图床
                Defaults[.selectedHostId] = firstHost.id
                return firstHost
            } else {
                AppLogger.uploader.error("[UPicUploader] 没有可用的图床配置")
                return nil
            }
        } catch {
            AppLogger.uploader.error("[UPicUploader] 获取备用图床配置失败：\(error.localizedDescription)")
            return nil
        }
    }

    /// 检查是否为图片文件扩展名
    private func isImageFileExtension(_ ext: String) -> Bool {
        let imageExtensions = ["png", "jpg", "jpeg", "gif", "webp", "bmp", "tiff", "ico", "svg"]
        return imageExtensions.contains(ext.lowercased())
    }

    /// 检查屏幕录制权限
    private func checkScreenRecordingPermission() -> Bool {
        // 简化的权限检查，实际项目中可能需要更复杂的实现
        return CGPreflightScreenCaptureAccess()
    }

    /// 请求屏幕录制权限
    private func requestScreenRecordingPermission() {
        CGRequestScreenCaptureAccess()
        // 显示权限请求提示
        let alert = NSAlert()
        alert.messageText = "需要屏幕录制权限"
        alert.informativeText = "请在系统偏好设置 > 安全性与隐私 > 屏幕录制中允许 uPic 访问。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "打开系统偏好设置")
        alert.addButton(withTitle: "取消")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
        }
    }
}

// MARK: - NSImage Extension

extension NSImage {
    /// 将NSImage转换为JPEG数据
    func jpegData(compressionQuality: CGFloat = 0.9) -> Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
    }
}
