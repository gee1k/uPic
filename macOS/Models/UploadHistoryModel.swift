//
//  UploadHistoryModel.swift
//  uPic
//
//  Created by Licardo on 2025/10/29.
//

import Foundation
import SwiftData

@Model
public final class UploadHistoryModel {
    public var id: String
    public var url: String
    public var thumbnailData: Data?
    public var createdDate: Date
    public var size: Int
    public var pixelWidth: Int
    public var pixelHeight: Int
    public var originalFilename: String?
    public var hostId: String?

    public init(
        url: String,
        thumbnailData: Data? = nil,
        createdDate: Date = Date(),
        size: Int = 0,
        pixelWidth: Int = 0,
        pixelHeight: Int = 0,
        originalFilename: String? = nil,
        hostId: String? = nil
    ) {
        self.id = UUID().uuidString
        self.url = url
        self.thumbnailData = thumbnailData
        self.createdDate = createdDate
        self.size = size
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.originalFilename = originalFilename
        self.hostId = hostId
    }

    // 计算属性
    public var filename: String? {
        return self.originalFilename ?? (self.url as NSString).lastPathComponent
    }

    public var fileExtension: String? {
        return (self.filename as NSString?)?.pathExtension
    }

    public var fileType: String? {
        guard let ext = self.fileExtension?.lowercased() else {
            return nil
        }
        return ext
    }

    public var formattedSize: String {
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .decimal)
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdDate)
    }
}
