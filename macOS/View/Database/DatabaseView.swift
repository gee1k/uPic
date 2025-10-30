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
                HistoryTable(uploadHistory: uploadHistory)
            }
        }
        .navigationTitle("Database")
    }
}

#Preview {
    DatabaseView()
        .modelContainer(for: [HostModel.self, UploadHistoryModel.self], inMemory: true)
}
