//
//  OutputType.swift
//  uPic
//
//  Created by Svend Jin on 2021/01/19.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Foundation
import WCDBSwift

class OutputFormatModel: TableCodable {
    var identifier: Int? = nil
    var name: String = ""
    var value: String = ""
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = OutputFormatModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case identifier
        case name
        case value
        
        
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                identifier: ColumnConstraintBinding(isPrimary: true),
            ]
        }
    }
    
    init() {
        self.name = ""
        self.value = ""
    }
    
    init(name: String , value: String) {
        self.name = name
        self.value = value
    }
    
    public var debugDescription: String {
        return "ID: \(identifier ?? 0), NAME: \(name), VALUE: \(value)"
    }
    
    static func getDefaultOutputFormats() -> [OutputFormatModel] {
        return [
            OutputFormatModel(name: "URL", value: "{url}"),
            OutputFormatModel(name: "HTML", value: "<img src=\"{url}\" alt=\"{filename}\"/>"),
            OutputFormatModel(name: "Markdown", value: "![{filename}]({url})"),
            OutputFormatModel(name: "UBB", value: "[img]{url}[/img]")
        ]
    }
    
    static func formatUrl(_ url: String, outputFormat: OutputFormatModel?) -> String {
        var formatUrl = url
        if Defaults[.outputFormatEncoded] {
            formatUrl = url.urlEncoded()
        }
        var filename = url.lastPathComponent.deletingPathExtension.trim()
        let tempArr = filename.components(separatedBy: .whitespaces).map{ $0.trim() }.filter{ !$0.isEmpty }
        filename = tempArr.joined(separator: "")
        
        var output = outputFormat
        if output == nil {
            output = ConfigManager.shared.getOutputType()
        }
        
        if output == nil {
            return formatUrl
        } else {
            return output!.value.replacingOccurrences(of: "{url}", with: formatUrl).replacingOccurrences(of: "{filename}", with: filename)
        }
        
        
    }
}
