//
//  HistoryMenuItem.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/30.
//

import QuickLook
import SwiftData
import SwiftUI
import UPicCore

struct HistoryMenuItem: View {
    let history: UploadHistoryModel
    @State private var quickLookURL: URL?

    @Query private var hostModels: [HostModel]

    @ObservedObject private var uploader = UploadeManager.shared

    @Environment(\.openURL) private var openURL

    private func getHost(for history: UploadHistoryModel) -> HostModel? {
        return hostModels.first { $0.id == history.hostId }
    }

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
                uploader.deleteHistory(history)
            }
        } label: {
            HStack {
                if let thumbnailData = history.thumbnailData, let nsImage = NSImage(data: thumbnailData) {
                    Image(nsImage: nsImage)
                } else {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 18, height: 18)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        )
                }

                Text(history.filename ?? "Unknown file")
                    .truncationMode(.middle)
            }
        }
    }
}

#Preview {
    HistoryMenuItem(history: UploadHistoryModel(
        url: "https://example.com/image.png",
        createdDate: Date(),
        size: 1024 * 1024,
        originalFilename: "test-image.png"
    ))
    .modelContainer(for: [HostModel.self, UploadHistoryModel.self], inMemory: true)
    .padding()
}
