//
//  DatabaseView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/29.
//

import SwiftUI
import SwiftData
import UPicCore

struct DatabaseView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UploadHistoryModel.createdDate, order: .reverse) private var uploadHistory: [UploadHistoryModel]

    @State private var selectedHistory: UploadHistoryModel?
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            VStack {
                if uploadHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text("暂无上传历史")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        Text("上传图片后，历史记录将显示在这里")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    historyList
                }
            }
            .navigationTitle("上传历史")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("清空") {
                        showingDeleteAlert = true
                    }
                    .disabled(uploadHistory.isEmpty)
                }
            }
            .alert("清空历史记录", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("清空", role: .destructive) {
                    clearAllHistory()
                }
            } message: {
                Text("确定要清空所有上传历史记录吗？此操作不可撤销。")
            }
        }
    }

    private var historyList: some View {
        List(uploadHistory, id: \.id, selection: $selectedHistory) { history in
            HistoryRowView(history: history)
        }
        .listStyle(.inset)
    }

    private func clearAllHistory() {
        for history in uploadHistory {
            modelContext.delete(history)
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to clear history: \(error)")
        }
    }
}

struct HistoryRowView: View {
    let history: UploadHistoryModel

    var body: some View {
        HStack(spacing: 12) {
            // 缩略图
            if let thumbnailData = history.thumbnailData,
               let nsImage = NSImage(data: thumbnailData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    )
            }

            // 文件信息
            VStack(alignment: .leading, spacing: 4) {
                // 文件名
                Text(history.filename ?? "未知文件")
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.middle)

                // URL
                Text(history.url)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // 日期和大小
                HStack {
                    Text(history.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(history.formattedSize)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let dimensions = history.dimensions {
                        Text(dimensions)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            copyToClipboard(history.url)
        }
        .contextMenu {
            Button("复制链接") {
                copyToClipboard(history.url)
            }

            Button("在浏览器中打开") {
                openInBrowser(history.url)
            }

            Divider()

            Button("删除", role: .destructive) {
                // 这里可以添加删除功能
            }
        }
    }

    private func copyToClipboard(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }

    private func openInBrowser(_ url: String) {
        guard let nsUrl = URL(string: url) else { return }
        NSWorkspace.shared.open(nsUrl)
    }
}

extension UploadHistoryModel {
    var dimensions: String? {
        guard pixelWidth > 0 && pixelHeight > 0 else { return nil }
        return "\(pixelWidth) × \(pixelHeight)"
    }
}

#Preview {
    DatabaseView()
        .modelContainer(for: [HostModel.self, UploadHistoryModel.self], inMemory: true)
}
