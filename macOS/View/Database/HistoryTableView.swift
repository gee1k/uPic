//
//  HistoryTableView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/29.
//

import QuickLook
import SimpleLogger
import SwiftData
import SwiftUI
import UPicCore

struct HistoryTableView: View {
    let uploadHistory: [UploadHistoryModel]
    @State private var selectedHistory = Set<UploadHistoryModel.ID>()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Query private var hostModels: [HostModel]

    @State private var showClearHistoryAlert: Bool = false
    @State private var quickLookURL: URL?
    @State private var thumbnailSize: CGFloat = 60

    // Sorting state - using SwiftUI's native sorting API
    @State private var sortedHistory: [UploadHistoryModel] = []
    @State private var sortOrder = [KeyPathComparator(\UploadHistoryModel.createdDate, order: .reverse)]

    var body: some View {
        VStack(spacing: 0) {
            HistoryMainTable(
                sortedHistory: sortedHistory,
                hostModels: hostModels,
                sortOrder: $sortOrder,
                selectedHistory: $selectedHistory,
                thumbnailSize: thumbnailSize
            )
            .onChange(of: sortOrder) { _, newOrder in
                sortedHistory.sort(using: newOrder)
            }
            .onChange(of: uploadHistory) { _, newHistory in
                sortedHistory = newHistory
                sortedHistory.sort(using: sortOrder)
            }
            .onAppear {
                sortedHistory = uploadHistory
                sortedHistory.sort(using: sortOrder)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        showClearHistoryAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .contextMenu(forSelectionType: UploadHistoryModel.ID.self) { selectedIds in
                let selectedHistories = selectedIds.compactMap { selectedId in
                    uploadHistory.first(where: { $0.id == selectedId })
                }

                Button("Copy URL", systemImage: "clipboard") {
                    Tools.shared.copyUrlsToClipboard(selectedHistories.compactMap { $0.url })
                }

                Button("Open in Browser", systemImage: "network") {
                    for history in selectedHistories {
                        if let url = URL(string: history.url) {
                            openURL(url)
                        }
                    }
                }

                if selectedHistories.count == 1 {
                    // Quick Look 只对第一个选中的项目
                    Divider()

                    Button("Quick Look", systemImage: "eye") {
                        if let firstHistory = selectedHistories.first, let url = URL(string: firstHistory.url) {
                            quickLookURL = url
                        }
                    }
                }

                Divider()

                Button("Delete", systemImage: "trash", role: .destructive) {
                    for history in selectedHistories {
                        deleteHistory(history)
                    }
                }
            } primaryAction: { selectedIds in
                let selectedUrls = selectedIds.compactMap { selectedId in
                    uploadHistory.first(where: { $0.id == selectedId })?.url
                }
                if !selectedUrls.isEmpty {
                    Tools.shared.copyUrlsToClipboard(selectedUrls)
                }
            }
            .alert("Clear History Record", isPresented: $showClearHistoryAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    clearAllHistory()
                }
            } message: {
                Text("Are you sure you want to clear all upload history? This action cannot be undone.")
            }
            .onKeyPress(.space) {
                handleSpaceKey()
                return .handled
            }
            .quickLookPreview($quickLookURL)
            .id(thumbnailSize)

            HStack(spacing: 2) {
                Text("\(uploadHistory.count) Items")

                Spacer()

                HStack(spacing: 2) {
                    Text("Thumbnail Size")
                    Image(systemName: "photo")
                }

                Slider(value: $thumbnailSize, in: 40 ... 120, step: 5)
                    .labelsHidden()
                    .frame(width: 120)
                Button {
                    thumbnailSize = 60
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .padding(.top, 4)
        }
    }

    private func deleteHistory(_ history: UploadHistoryModel) {
        modelContext.delete(history)
        do {
            try modelContext.save()
        } catch {
            AppLogger.history.error("Failed to delete history: \(error.localizedDescription)")
        }
    }

    private func clearAllHistory() {
        for history in uploadHistory {
            modelContext.delete(history)
        }

        do {
            try modelContext.save()
        } catch {
            AppLogger.history.error("Failed to clear history: \(error.localizedDescription)")
        }
    }

    private func handleSpaceKey() {
        guard let selectedId = selectedHistory.first, let history = uploadHistory.first(where: { $0.id == selectedId }), let url = URL(string: history.url) else {
            return
        }

        quickLookURL = url
    }
}

struct ThumbnailView: View {
    let history: UploadHistoryModel
    let size: CGFloat

    var body: some View {
        Group {
            if let nsImage = NSImage(data: history.thumbnailData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size - 10, height: size - 10)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size - 10, height: size - 10)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: size / 4))
                            .foregroundStyle(.secondary)
                    )
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HistoryTableView(uploadHistory: [])
        .modelContainer(for: [HostModel.self, UploadHistoryModel.self], inMemory: true)
}
