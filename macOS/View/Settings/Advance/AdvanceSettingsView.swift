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
            OutputFormatSettings()
            ScreenshotAppSettings()
        }
        .navigationTitle("Advance")
        .formStyle(.grouped)
    }
}

#Preview {
    AdvanceSettingsView()
}
