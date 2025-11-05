//
//  UPicUploadFile.swift
//  uPicAppIntentsExtension
//
//  Created by Licardo on 2025/11/5.
//
 
import AppIntents
import AppKit
import Foundation
import SimpleLogger
 
// MARK: - Upload File Intent
 
struct UPicUploadFile: AppIntent {
    static var title: LocalizedStringResource = "Upload File with uPic"
    static var description = IntentDescription("Upload a file to with uPic to default host by providing the file path.")
 
    @Parameter(title: "File Path", description: "Enter the path of the file to upload.")
    var filePath: String
 
    static var parameterSummary: some ParameterSummary {
        Summary("Upload file \(\.$filePath)")
    }
 
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        if FileManager.default.fileExists(atPath: filePath) {
            // 通过 URL Scheme 调用主应用
            let encodedPath = filePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? filePath
            let urlString = "uPic://files?\(encodedPath)"
 
            if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
            AppLogger.appIntentsExtension.info("Successfully processed file: \(filePath)")
            return .result(value: encodedPath)
        }
 
        return .result(value: String(localized: "File does not exist: \(filePath)"))
    }
}
