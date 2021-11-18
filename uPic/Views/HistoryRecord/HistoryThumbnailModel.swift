//
//  PreViewModel.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/25.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa
import WCDBSwift

class HistoryThumbnailModel: TableCodable {
    var identifier: Int? = nil
    var url: String = ""
    var previewWidth: Double = 0
    var previewHeight: Double = 0
    var thumbnailData: Data?
    var createdDate: Date = Date()
    var size: Int = 0
    var host: String?
    var isImage: Bool = false
    
    var isAutoIncrement: Bool { return true }
    
    // dynamic
    var fileName: String {
        return url.lastPathComponent
    }
    
    var ext: String? {
        return url.lastPathComponent.pathExtension
    }
    
    var thumbnailSize: NSSize {
        return NSSize(width: thumbnailWidth, height: thumbnailHeight)
    }
    var thumbnailWidth: CGFloat {
        return PreviewWidthGlobal
    }
    var thumbnailHeight: CGFloat {
        var height: CGFloat = 0
        guard let imageData = thumbnailData, let image = NSImage(data: imageData) else {
            height = thumbnailWidth * 0.5 + 20
            return height
        }
        height = thumbnailWidth * (image.size.height / image.size.width) + 20
        return height
    }
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = HistoryThumbnailModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case identifier
        case url
        case previewWidth
        case previewHeight
        case thumbnailData
        case createdDate
        case size
        case host
        case isImage
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                identifier: ColumnConstraintBinding(isPrimary: true),
            ]
        }
    }
    
    static func keyValue(keyValue: [String: Any]) -> HistoryThumbnailModel {
        let model = HistoryThumbnailModel()
        model.url = keyValue["url"] as! String
        model.previewWidth = keyValue["previewWidth"] as! Double
        model.previewHeight = keyValue["previewHeight"] as! Double
        model.thumbnailData = keyValue["thumbnailData"] as? Data
        if let createDateStr = keyValue["createdDate"] as? String, !createDateStr.isEmpty {
            model.createdDate = Date.dateFromISOString(string: createDateStr)!
        } else {
            model.createdDate = Date()
        }
        model.size = keyValue["size"] as? Int ?? 0
        model.host = keyValue["host"] as? String
        model.isImage = keyValue["isImage"] as! Bool
        return model
    }
    
    func toKeyValue() -> [String: Any] {
        var historyKeyValue: [String: Any] = [:]
        historyKeyValue["url"] = url
        historyKeyValue["previewWidth"] = previewWidth
        historyKeyValue["previewHeight"] = previewHeight
        if let thumbnailData = thumbnailData {
            historyKeyValue["thumbnailData"] = thumbnailData
        }
        
        historyKeyValue["createdDate"] = createdDate.toISOString()
        historyKeyValue["size"] = size
        historyKeyValue["host"] = host
        historyKeyValue["isImage"] = isImage
        return historyKeyValue
    }
    
}
