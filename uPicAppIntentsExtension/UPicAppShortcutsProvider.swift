//
//  UPicAppShortcutsProvider.swift
//  uPicAppIntentsExtension
//
//  Created by Licardo on 2025/11/5.
//

import AppIntents

// MARK: - App Shortcuts Provider

struct UPicAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: uPicUploadFile(),
            phrases: [
                "Upload file with \(.applicationName)",
                "Upload \(.applicationName) file"
            ],
            shortTitle: "Upload File",
            systemImageName: "icloud.and.arrow.up"
        )
    }
}
