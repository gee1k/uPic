//
//  AdvanceSettingsView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI

struct AdvanceSettingsView: View {
    var body: some View {
        Form {
            KeyboardShortcutsSettings()
            HistoryRecordSettings()
            OutputFormatSettings()
            ScreenshotAppSettings()
        }
        .formStyle(.grouped)
    }
}

#Preview {
    AdvanceSettingsView()
}
