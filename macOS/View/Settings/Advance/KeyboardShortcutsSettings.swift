//
//  KeyboardShortcutsSettings.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import KeyboardShortcuts
import SwiftUI

struct KeyboardShortcutsSettings: View {
    var body: some View {
        Section {
            HStack {
                Label {
                    Text("Upload from Select File")
                } icon: {
                    Image(systemName: "folder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                Spacer()
                KeyboardShortcuts.Recorder(for: .uploadFromSelectFile)
            }

            HStack {
                Label {
                    Text("Upload from Clipboard")
                } icon: {
                    Image(systemName: "list.bullet.clipboard")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                Spacer()
                KeyboardShortcuts.Recorder(for: .uploadFromClipboard)
            }

            HStack {
                Label {
                    Text("Upload from Screenshot")
                } icon: {
                    Image(systemName: "rectangle.dashed")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                Spacer()
                KeyboardShortcuts.Recorder(for: .uploadFromScreenshot)
            }
        } header: {
            Text("Keyboard Shortcuts")
        }
    }
}

#Preview {
    Form {
        KeyboardShortcutsSettings()
    }
    .formStyle(.grouped)
}
