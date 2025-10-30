//
//  OutputType.swift
//  uPic
//
//  Created by Svend Jin on 2021/01/19.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Defaults
import Foundation

struct OutputFormatModel: Identifiable, Codable, Equatable, Hashable, Defaults.Serializable {
    var id = UUID()
    var name: String
    var value: String
}

extension OutputFormatModel {
    static func getDefaultOutputFormats() -> [OutputFormatModel] {
        return [
            OutputFormatModel(id: UUID(uuidString: "a88ff400-a684-4bea-ae9b-8fe3cf74b453")!, name: "URL", value: "{url}"),
            OutputFormatModel(id: UUID(uuidString: "a88ff400-a684-4bea-ae9b-8fe3cf74b454")!, name: "HTML", value: "<img src=\"{url}\" alt=\"{filename}\"/>"),
            OutputFormatModel(id: UUID(uuidString: "a88ff400-a684-4bea-ae9b-8fe3cf74b455")!, name: "Markdown", value: "![{filename}]({url})"),
            OutputFormatModel(id: UUID(uuidString: "a88ff400-a684-4bea-ae9b-8fe3cf74b456")!, name: "UBB", value: "[img]{url}[/img]")
        ]
    }

    static func formatUrl(_ url: String, outputFormat: OutputFormatModel?) -> String {
        var formatUrl = url
        if Defaults[.outputFormatEncoded] {
            formatUrl = url.urlEncoded()
        }
        var filename = url.lastPathComponent.deletingPathExtension.trim()
        let tempArr = filename.components(separatedBy: .whitespaces).map { $0.trim() }.filter { !$0.isEmpty }
        filename = tempArr.joined(separator: "")

        var output = outputFormat
        if output == nil {
            output = Defaults[.selectedOutputFormat]
        }

        if output == nil {
            return formatUrl
        } else {
            return output!.value.replacingOccurrences(of: "{url}", with: formatUrl).replacingOccurrences(of: "{filename}", with: filename)
        }
    }
}
