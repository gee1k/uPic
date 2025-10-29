//
//  HistoryTable.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/29.
//

import SwiftData
import SwiftUI
import UPicCore

struct HistoryTable: View {
    let uploadHistory: [UploadHistoryModel]
    @State private var selectedHistory = Set<UploadHistoryModel.ID>()
    @Environment(\.modelContext) private var modelContext

    @State private var showClearHistoryAlert: Bool = false

    var body: some View {
        Table(uploadHistory, selection: $selectedHistory) {
            TableColumn("Thumbnail") { history in
                ThumbnailView(history: history)
            }
            .width(80)

            TableColumn("File Name") { history in
                Text(history.filename ?? "未知文件")
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            TableColumn("URL") { history in
                Text(history.url)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundColor(.secondary)
            }

            TableColumn("Size") { history in
                if let dimensions = history.dimensions {
                    Text(dimensions)
                        .foregroundColor(.secondary)
                } else {
                    Text("-")
                        .foregroundColor(.secondary)
                }
            }
            .width(80)

            TableColumn("Frame") { history in
                Text(history.formattedSize)
                    .foregroundColor(.secondary)
            }
            .width(80)

            TableColumn("Upload Time") { history in
                Text(history.formattedDate)
                    .foregroundColor(.secondary)
            }
            .width(120)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showClearHistoryAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .contextMenu(forSelectionType: UploadHistoryModel.self) { selectedItems in
            if let history = selectedItems.first {
                Button("复制链接") {
                    copyToClipboard(history.url)
                }

                Button("在浏览器中打开") {
                    openInBrowser(history.url)
                }

                Divider()

                Button("删除", role: .destructive) {
                    deleteHistory(history)
                }
            }
        } primaryAction: { selectedItems in
            if let history = selectedItems.first {
                copyToClipboard(history.url)
            }
        }
        .alert("清空历史记录", isPresented: $showClearHistoryAlert) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                clearAllHistory()
            }
        } message: {
            Text("确定要清空所有上传历史记录吗？此操作不可撤销。")
        }
    }

    private func deleteHistory(_ history: UploadHistoryModel) {
        modelContext.delete(history)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete history: \(error)")
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

struct ThumbnailView: View {
    let history: UploadHistoryModel

    var body: some View {
        Group {
            if let thumbnailData = history.thumbnailData, let nsImage = NSImage(data: thumbnailData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    )
            }
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {
    HistoryTable(uploadHistory: [])
        .modelContainer(for: [HostModel.self, UploadHistoryModel.self], inMemory: true)
}
