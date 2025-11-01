//
//  HistoryTableView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/29.
//

import QuickLook
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
                if let selectedId = selectedIds.first, let history = uploadHistory.first(where: { $0.id == selectedId }) {
                    Button("Preview", systemImage: "eye") {
                        if let url = URL(string: history.url) {
                            quickLookURL = url
                        }
                    }

                    Button("Copy URL", systemImage: "clipboard") {
                        Tools.shared.copyUrls([history.url])
                    }

                    Button("Open in Browser", systemImage: "network") {
                        if let url = URL(string: history.url) {
                            openURL(url)
                        }
                    }

                    Divider()

                    Button("Delete", systemImage: "trash", role: .destructive) {
                        deleteHistory(history)
                    }
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
                Spacer()

                HStack(spacing: 2) {
                    Text("Thumbnail Size")
                    Image(systemName: "photo")
                }
                .foregroundStyle(.secondary)
                .font(.caption)

                Slider(value: $thumbnailSize, in: 40 ... 120, step: 5) {}
                    .labelsHidden()
                    .frame(width: 100)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 8)
            .background(Color(NSColor.controlBackgroundColor))
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
