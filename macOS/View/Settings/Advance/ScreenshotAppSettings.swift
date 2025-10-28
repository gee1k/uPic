//
//  ScreenshotAppSettings.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import Defaults

struct ScreenshotAppSettings: View {
    @Default(.screenshotApp) var screenshotApp
    
    var body: some View {
        Section {
            HStack {
                Label("Screenshot App", systemImage: "rectangle.dashed")
                Spacer()
                Picker("", selection: $screenshotApp) {
                    ForEach(ScreenshotApp.allCases, id: \.self) { screenshotApp in
                        Label {
                            Text(screenshotApp.displayName)
                        } icon: {
                            screenshotApp.icon
                        }
                    }
                }
                .labelsHidden()
            }
        } header: {
            Text("Screenshot App")
        }
    }
}

#Preview {
    Form {
        ScreenshotAppSettings()
    }
    .formStyle(.grouped)
}
