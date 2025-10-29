//
//  HistoryModel.swift
//  uPic
//
//  Created by Svend Jin on 2020/1/14.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation
import WCDBSwift

class HistoryModel: TableCodable {
    
    var identifier: Int? = nil
    var url: String = ""
    var thumbnailData: Data?
    var createdDate: Date = Date()
    var size: Int = 0
    var pixelWidth: Int = 0
    var pixelHeight: Int = 0
    var originalFilename: String?
    var filename: String? {
        return self.originalFilename ?? (self.url as NSString).lastPathComponent
    }
    var ext: String? {
        return (self.filename as NSString?)?.pathExtension
    }
    var type: String? {
        guard let ext = self.ext?.lowercased() else {
            return nil
        }
        return ext.fileType
    }
    
    var isAutoIncrement: Bool { return true }
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = HistoryModel
        case identifier
        case url
        case thumbnailData
        case createdDate
        case size
        case pixelWidth
        case pixelHeight
        case originalFilename
        
        static let objectRelationalMapping = TableBinding(CodingKeys.self) {
            BindColumnConstraint(identifier, isPrimary: true)
        }
    }
}
