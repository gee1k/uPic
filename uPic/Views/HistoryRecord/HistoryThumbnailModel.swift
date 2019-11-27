//
//  PreViewModel.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/25.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa

struct HistoryThumbnailModel {
    var url: String = ""
    var fileName: String?
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
    var previewWidth: CGFloat = 0
    var previewHeight: CGFloat = 0
    var thumbnailData: Data?
    var isImage: Bool = false
    
    static func keyValue(keyValue: [String: Any]) -> HistoryThumbnailModel {
        var model = HistoryThumbnailModel()
        model.url = keyValue["url"] as! String
        model.fileName = keyValue["fileName"] as? String
        model.previewWidth = keyValue["previewWidth"] as! CGFloat
        model.previewHeight = keyValue["previewHeight"] as! CGFloat
        model.thumbnailData = keyValue["thumbnailData"] as? Data
        model.isImage = keyValue["isImage"] as! Bool
        return model
    }
    
    func toKeyValue() -> [String: Any] {
        var historyKeyValue: [String: Any] = [:]
        historyKeyValue["url"] = url
        historyKeyValue["fileName"] = fileName
        historyKeyValue["previewWidth"] = previewWidth
        historyKeyValue["previewHeight"] = previewHeight
        if let thumbnailData = thumbnailData {
            historyKeyValue["thumbnailData"] = thumbnailData
        }
        historyKeyValue["isImage"] = isImage
        return historyKeyValue
    }
    
}
