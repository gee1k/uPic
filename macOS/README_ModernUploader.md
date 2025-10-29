# ModernUploader 使用指南

## 概述

`ModernUploader` 是一个基于 SwiftUI、SwiftData 和 async/await 的现代化上传器，专为 uPic v2 设计。它提供了完整的上传功能，包括历史记录保存、进度追踪和错误处理。

## 主要特性

- ✅ **现代化架构**: 使用 SwiftUI + SwiftData + async/await
- ✅ **历史记录管理**: 自动保存上传历史到本地数据库
- ✅ **进度追踪**: 实时显示上传进度和状态
- ✅ **错误处理**: 完善的错误处理和用户通知
- ✅ **多种输入**: 支持文件URL、Data、NSImage等多种输入方式
- ✅ **缩略图生成**: 自动生成图片缩略图
- ✅ **HEIC转换**: 自动将HEIC格式转换为JPEG

## 文件结构

```
macOS/
├── Models/
│   └── UploadHistory.swift      # SwiftData 历史记录模型
├── Services/
│   └── ModernUploader.swift     # 主上传器类
├── View/
│   ├── Database/
│   │   └── DatabaseView.swift   # 历史记录查看界面
│   └── UploadDemoView.swift     # 上传演示界面
```

## 核心组件

### 1. UploadHistory (SwiftData 模型)

```swift
@Model
public final class UploadHistory {
    public var id: String
    public var url: String
    public var thumbnailData: Data?
    public var createdDate: Date
    public var size: Int
    public var pixelWidth: Int
    public var pixelHeight: Int
    public var originalFilename: String?
    public var hostId: String?

    // 计算属性
    public var filename: String?
    public var fileExtension: String?
    public var fileType: String?
    public var formattedSize: String
    public var formattedDate: String
}
```

### 2. ModernUploader (主上传器)

```swift
@MainActor
public class ModernUploader: ObservableObject {
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0.0
    @Published var currentUploadingItem: Data? = nil
    @Published var uploadHistory: [UploadHistory] = []

    // 回调函数
    public var onUploadStart: (() -> Void)?
    public var onUploadComplete: ((String) -> Void)?
    public var onUploadFail: ((String, String?) -> Void)?
    public var onAllUploadsComplete: (() -> Void)?

    // 上传方法
    public func upload(hostModel: HostModel, fileURLs: [URL]) async
    public func upload(hostModel: HostModel, fileData: Data, filename: String?) async
    public func upload(hostModel: HostModel, images: [NSImage]) async
}
```

## 使用方法

### 基本使用

```swift
import SwiftUI
import SwiftData
import UPicCore

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var uploader = ModernUploader(modelContext: modelContext)

    var body: some View {
        VStack {
            if uploader.isUploading {
                ProgressView(value: uploader.uploadProgress)
                Text("上传中...")
            } else {
                Button("上传文件") {
                    uploadFiles()
                }
            }
        }
        .onAppear {
            setupUploaderCallbacks()
        }
    }

    private func setupUploaderCallbacks() {
        uploader.onUploadStart = {
            print("开始上传")
        }

        uploader.onUploadComplete = { url in
            print("上传成功: \(url)")
        }

        uploader.onUploadFail = { errorMessage, detailError in
            print("上传失败: \(errorMessage)")
        }

        uploader.onAllUploadsComplete = {
            print("所有上传完成")
        }
    }

    private func uploadFiles() {
        guard let hostModel = getHostModel() else { return }

        Task {
            await uploader.upload(hostModel: hostModel, fileURLs: fileUrls)
        }
    }
}
```

### 数据库配置

确保在 `uPicApp.swift` 中包含 `UploadHistory` 模型：

```swift
var upicModelContainer: ModelContainer = {
    let schema = Schema([
        HostModel.self,
        UploadHistory.self,  // 添加这一行
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
```

## 上传流程

1. **文件准备**: 支持多种输入方式（URL、Data、NSImage）
2. **格式转换**: 自动处理HEIC格式转换
3. **缩略图生成**: 生成JPEG格式的缩略图
4. **上传执行**: 使用UPicCore进行实际上传
5. **历史保存**: 上传成功后自动保存到数据库
6. **通知更新**: 发送通知更新UI

## 回调函数

```swift
uploader.onUploadStart = {
    // 开始上传时调用
}

uploader.onUploadComplete = { url in
    // 单个文件上传成功时调用
}

uploader.onUploadFail = { errorMessage, detailError in
    // 上传失败时调用
}

uploader.onAllUploadsComplete = {
    // 所有文件上传完成时调用
}
```

## 历史记录管理

### 查看历史记录

```swift
// 自动加载到 uploadHistory 属性中
let history = uploader.uploadHistory

// 或者直接查询 SwiftData
let descriptor = FetchDescriptor<UploadHistory>(sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
let history = try modelContext.fetch(descriptor)
```

### 删除历史记录

```swift
// 删除单个记录
uploader.deleteHistory(historyItem)

// 清空所有记录
uploader.clearAllHistory()
```

## 通知

上传器会发送以下通知：

- `uploadHistoryDidUpdate`: 历史记录更新时

```swift
NotificationCenter.default.addObserver(
    forName: .uploadHistoryDidUpdate,
    object: nil,
    queue: .main
) { _ in
    // 处理历史记录更新
}
```

## 错误处理

上传器会自动处理以下错误情况：

- 文件读取失败
- 网络连接错误
- 图床配置无效
- 上传失败

所有错误都会通过 `onUploadFail` 回调传递，并显示系统通知。

## 注意事项

1. **MainActor**: `ModernUploader` 使用 `@MainActor`，确保UI更新在主线程进行
2. **SwiftData**: 确保正确配置SwiftData模型容器
3. **内存管理**: 大文件上传时注意内存使用
4. **错误处理**: 始终设置错误回调以获得更好的用户体验

## 扩展

你可以轻松扩展 `ModernUploader` 来支持更多功能：

- 添加更多输入格式支持
- 自定义通知方式
- 实现批量操作
- 添加上传队列管理
- 支持断点续传

这个现代化上传器为 uPic v2 提供了强大而灵活的上传功能，同时保持了代码的简洁性和可维护性。