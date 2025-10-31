//
//  DatabaseView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/29.
//

import SwiftData
import SwiftUI
import UPicCore

struct DatabaseView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UploadHistoryModel.createdDate, order: .reverse) private var uploadHistory: [UploadHistoryModel]

    var body: some View {
        Form {
            if uploadHistory.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 60))

                    Text("No upload history")
                        .font(.title2)

                    Text("After uploading images, the history will be displayed here.")
                        .font(.body)
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HistoryTable(uploadHistory: uploadHistory)
            }
        }
        .navigationTitle("Database")
        .onAppear {
            NSApp.setActivationPolicy(.regular)
        }
        .onDisappear {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

#Preview {
    DatabaseView()
        .modelContainer(for: [HostModel.self, UploadHistoryModel.self], inMemory: true)
}
