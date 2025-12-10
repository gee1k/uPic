//
//  Tools.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/30.
//

import AppKit
import SimpleLogger
import UPicCore

class Tools {
    static let shared = Tools()

    func copyUrlsToClipboard(_ urls: [String], afterUpload: Bool = false) {
        let outputUrls = formatOutputUrls(urls)
        let outputStr = outputUrls.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(outputStr, forType: .string)

        AppLogger.tools.info("Copy upload result to clipboard: \(outputStr)")

        if afterUpload {
            Noti.shared.postUploadAndCopyToClipboardSuccessful(outputStr)
        } else {
            Noti.shared.postCopyToClipboardSuccessful(outputStr)
        }
    }

    func formatOutputUrls(_ urls: [String], _ outputType: OutputFormatModel? = nil) -> [String] {
        let outputUrls = urls.map { url in
            OutputFormatModel.formatUrl(url, outputFormat: outputType)
        }
        return outputUrls
    }
}
