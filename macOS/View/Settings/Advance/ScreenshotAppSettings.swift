//
//  ScreenshotAppSettings.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import Defaults
import SwiftUI

struct ScreenshotAppSettings: View {
    @Default(.screenshotApp) var screenshotApp
    @Default(.customScreenshotAppUlrScheme) var customScreenShotAppUlrscheme
    @ObservedObject private var uploader = UploadManager.shared

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

                Button("Test") {
                    uploader.uploadFromScreenshot()
                }
            }

            if screenshotApp == .x_callback_url {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(verbatim: "URL Scheme")
                        Spacer()
                        VStack(alignment: .trailing) {
                            TextField("", text: $customScreenShotAppUlrscheme, axis: .vertical)
                                .labelsHidden()
                                .textFieldStyle(.roundedBorder)
                            Text("You can use uPic://x-callback-url/acceptSnip to trigger an upload after a screenshot is taken, uPic will upload the screen shot image from clipboard.")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .textSelection(.enabled)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
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
