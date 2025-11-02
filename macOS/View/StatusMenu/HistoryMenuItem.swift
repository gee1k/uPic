//
//  HistoryMenuItem.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/30.
//

import QuickLook
import SimpleLogger
import SwiftData
import SwiftUI
import UPicCore

struct HistoryMenuItem: View {
    let history: UploadHistoryModel
    @State private var quickLookURL: URL?

    @Query private var uploadHistory: [UploadHistoryModel]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    var body: some View {
        Menu {
            Button("Copy URL", systemImage: "clipboard") {
                Tools.shared.copyUrls([history.url])
            }

            Button("Open in Browser", systemImage: "globe") {
                if let url = URL(string: history.url) {
                    openURL(url)
                }
            }

            Divider()

            Button("Preview", systemImage: "eye") {
                if let url = URL(string: history.url) {
                    quickLookURL = url
                }
            }
            .quickLookPreview($quickLookURL)

            Divider()

            Button("Delete", systemImage: "trash", role: .destructive) {
                deleteHistory(history)
            }
        } label: {
            HStack {
                if let nsImage = NSImage(data: history.thumbnailData) {
                    Image(nsImage: nsImage)
                } else {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 18, height: 18)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        )
                }

                Text(history.filename ?? "Unknown")
                    .truncationMode(.middle)
            }
        } primaryAction: {
            Tools.shared.copyUrls([history.url])
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
}

#Preview {
    HistoryMenuItem(history: UploadHistoryModel(
        url: "https://example.com/image.png",
        thumbnailData: Data(),
        createdDate: Date(),
        size: 1024 * 1024,
        originalFilename: "test-image.png",
        hostType: "",
        hostName: ""
    ))
    .modelContainer(for: [HostModel.self, UploadHistoryModel.self], inMemory: true)
    .padding()
}
