//
//  UploadDemoView.swift
//  uPic
//
//  Created by Licardo on 2025/10/29.
//

import SwiftUI
import SwiftData
import UPicCore
import UniformTypeIdentifiers

struct UploadDemoView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject private var uploader = UploadeManager.shared
    @State private var isShowingFilePicker = false
    @State private var selectedHost: HostModel?
    @State private var hasDiskPermissions = false

    var body: some View {
        VStack(spacing: 30) {
            Text("上传演示")
                .font(.largeTitle)
                .fontWeight(.bold)

            // 权限状态显示
            permissionStatusView

            if uploader.isUploading {
                VStack(spacing: 20) {
                    ProgressView(value: uploader.uploadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 200)

                    Text("上传中... \(Int(uploader.uploadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let currentData = uploader.currentUploadingItem,
                       let image = NSImage(data: currentData) {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 20) {
                    // 文件选择按钮
                    Button("选择文件上传") {
                        isShowingFilePicker = true
                    }
                    .buttonStyle(.borderedProminent)

                    // 拖拽区域
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 300, height: 200)
                        .overlay(
                            VStack(spacing: 12) {
                                Image(systemName: "arrow.down.doc")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)

                                Text("拖拽文件到这里")
                                    .font(.title3)
                                    .foregroundColor(.secondary)

                                Text("支持图片格式")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                            handleDroppedFiles(providers: providers)
                            return true
                        }
                }
            }
        }
        .padding(30)
        .frame(minWidth: 500, minHeight: 600)
        .onAppear {
            checkPermissions()
        }
        .fileImporter(
            isPresented: $isShowingFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result: result)
        }
    }

    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let host = getSelectedHost() else {
                print("没有可用的图床配置")
                return
            }

            Task {
                await uploader.upload(hostModel: host, fileURLs: urls)
            }

        case .failure(let error):
            print("文件选择失败: \(error)")
        }
    }

    private func handleDroppedFiles(providers: [NSItemProvider]) {
        guard let host = getSelectedHost() else {
            print("没有可用的图床配置")
            return
        }

        var urls: [URL] = []

        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (item, error) in
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    urls.append(url)
                }
            }
        }

        if !urls.isEmpty {
            Task {
                await uploader.upload(hostModel: host, fileURLs: urls)
            }
        }
    }

    private func getSelectedHost() -> HostModel? {
        // 这里应该从配置中获取选中的图床
        // 暂时返回一个示例配置
        let descriptor = FetchDescriptor<HostModel>()
        do {
            let hosts = try modelContext.fetch(descriptor)
            return hosts.first
        } catch {
            print("获取图床配置失败: \(error)")
            return nil
        }
    }

    // MARK: - Permission Management

    private func checkPermissions() {
        hasDiskPermissions = uploader.checkDiskPermissions()
    }

    private func requestPermissions() {
        uploader.requestDiskPermissions()

        // 延迟检查权限状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            checkPermissions()
        }
    }

    // MARK: - Views

    @ViewBuilder
    private var permissionStatusView: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Disk Access Permission", systemImage: hasDiskPermissions ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(hasDiskPermissions ? .green : .orange)

                Spacer()

                if hasDiskPermissions {
                    Text("Granted")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    HStack(spacing: 8) {
                        Button("Request Permission") {
                            requestPermissions()
                        }
                        .controlSize(.small)

                        Button("System Settings") {
                            uploader.openSystemPreferences()
                        }
                        .controlSize(.small)
                    }
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            if !hasDiskPermissions {
                Text("Disk access permission is required to upload files from anywhere on your Mac")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    UploadDemoView()
        .modelContainer(for: [HostModel.self, UploadHistoryModel.self], inMemory: true)
}
