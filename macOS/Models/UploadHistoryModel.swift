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
    public var id: String = ""
    public var url: String = ""
    public var thumbnailData: Data = Data()
    public var createdDate: Date = Date()
    public var size: Int = 0
    public var pixelWidth: Int = 0
    public var pixelHeight: Int = 0
    public var originalFilename: String = ""
    public var hostType: String = ""
    public var hostName: String = ""

    public init(
        url: String,
        thumbnailData: Data,
        createdDate: Date = Date(),
        size: Int = 0,
        pixelWidth: Int = 0,
        pixelHeight: Int = 0,
        originalFilename: String,
        hostType: String,
        hostName: String
    ) {
        self.id = UUID().uuidString
        self.url = url
        self.thumbnailData = thumbnailData
        self.createdDate = createdDate
        self.size = size
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.originalFilename = originalFilename
        self.hostType = hostType
        self.hostName = hostName
    }

    // 计算属性
    public var filename: String? {
        return originalFilename.isEmpty ? (url as NSString).lastPathComponent : originalFilename
    }

    public var fileExtension: String? {
        return (filename as NSString?)?.pathExtension
    }

    public var fileType: String? {
        guard let ext = fileExtension?.lowercased() else {
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

    public var frame: String {
        guard pixelWidth > 0, pixelHeight > 0 else {
            return "-"
        }
        return "\(pixelWidth)×\(pixelHeight)px"
    }
}
