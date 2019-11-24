//
//  PreViewModel.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/25.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

struct HistoryThumbnailModel {
    var url: String = ""
    var fileName: String?
    var thumbnailWidth: CGFloat = 0
    var thumbnailHeight: CGFloat = 0
    var previewWidth: CGFloat = 0
    var previewHeight: CGFloat = 0
    var thumbnailData: Data?
    var isImage: Bool = false
    
    static func keyValue(keyValue: [String: Any]) -> HistoryThumbnailModel {
        var model = HistoryThumbnailModel()
        model.url = keyValue["url"] as! String
        model.fileName = keyValue["fileName"] as? String
        model.thumbnailWidth = keyValue["thumbnailWidth"] as! CGFloat
        model.thumbnailHeight = keyValue["thumbnailHeight"] as! CGFloat
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
        historyKeyValue["thumbnailWidth"] = thumbnailWidth
        historyKeyValue["thumbnailHeight"] = thumbnailHeight
        historyKeyValue["previewWidth"] = previewWidth
        historyKeyValue["previewHeight"] = previewHeight
        if let thumbnailData = thumbnailData {
            historyKeyValue["thumbnailData"] = thumbnailData
        }
        historyKeyValue["isImage"] = isImage
        return historyKeyValue
    }
    
}
