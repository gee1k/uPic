//
//  uPicUploadFile.swift
//  uPicAppIntentsExtension
//
//  Created by Licardo on 2025/11/5.
//

import AppIntents

struct uPicUploadFile: AppIntent {
    static var title: LocalizedStringResource = "Upload a file"
    static var description: IntentDescription = "Upload a file to default host"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
