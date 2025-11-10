//
//  SortableHistoryTable.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/11/01.
//

import AppKit
import SwiftData
import SwiftUI
import UPicCore

struct HistoryMainTable: View {
    let sortedHistory: [UploadHistoryModel]
    let hostModels: [HostModel]
    @Binding var sortOrder: [KeyPathComparator<UploadHistoryModel>]
    @Binding var selectedHistory: Set<UploadHistoryModel.ID>
    let thumbnailSize: CGFloat

    var body: some View {
        Table(sortedHistory, selection: $selectedHistory, sortOrder: $sortOrder) {
            TableColumn("Thumbnail") { history in
                ThumbnailView(history: history, size: thumbnailSize)
            }
            .width(thumbnailSize + 20)

            TableColumn("Host", value: \.hostName) { history in
                if !history.hostType.isEmpty, !history.hostName.isEmpty {
                    HStack(spacing: 4) {
                        Image("host_icon_\(history.hostType)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text(history.hostName)
                            .lineLimit(1)
                    }
                } else {
                    Text("Unknown")
                }
            }
            .width(ideal: 50)

            TableColumn("File Name", value: \.originalFilename) { history in
                Text(history.filename ?? "Unknown")
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .width(ideal: 80)

            TableColumn("URL", value: \.url) { history in
                Text(history.url)
                    .lineLimit(2)
                    .truncationMode(.middle)
            }
            .width(ideal: 120)

            TableColumn("Frame", value: \.pixelWidth) { history in
                Text(history.frame)
            }
            .width(ideal: 50)

            TableColumn("Size", value: \.size) { history in
                Text(history.formattedSize)
            }
            .width(ideal: 50)

            TableColumn("Upload Time", value: \.createdDate) { history in
                Text(history.formattedDate)
            }
            .width(ideal: 160)
        }
    }
}

#Preview {
    HistoryMainTable(
        sortedHistory: [],
        hostModels: [],
        sortOrder: .constant([KeyPathComparator(\UploadHistoryModel.createdDate, order: .reverse)]),
        selectedHistory: .constant([]),
        thumbnailSize: 60
    )
    .modelContainer(for: [HostModel.self, UploadHistoryModel.self], inMemory: true)
}
