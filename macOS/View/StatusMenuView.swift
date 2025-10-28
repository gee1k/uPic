//
//  StatusMenuView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import Defaults
import KeyboardShortcuts
import SwiftUI

struct StatusMenuView: View {
    @Default(.isUploading) var isUploading
    @Default(.screenshotApp) var screenshotApp
    @Default(.selectedOutputFormat) var selectedOutputFormat
    @Default(.outputFormats) var outputFormats
    @Default(.outputFormatEncoded) var outputFormatEncoded
    @Default(.compressFactor) var compressFactor
    
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        VStack {
            if isUploading {
                Button("Cancel upload") {
                    print("取消上传")
                }
                Divider()
            }
            
            Button("Upload from select file") {
                print("Upload from select file")
            }
            .globalKeyboardShortcut(.uploadFromSelectFile)
            
            Button("Upload from clipboard") {
                print("Upload from clipboard")
            }
            .globalKeyboardShortcut(.uploadFromClipboard)
            
            Button("Upload from screenshot  \(Text(screenshotApp.displayName).foregroundStyle(.secondary))") {
                print("Upload from screenshot")
            }
            .globalKeyboardShortcut(.uploadFromScreenshot)
    
            Menu("Host  \(Text("Host").foregroundStyle(.secondary))") {
                Button("Upload from clipboard") {
                    print("Upload from clipboard")
                }
            }
            
            Menu("Output format  \(Text(selectedOutputFormat.name).foregroundStyle(.secondary))") {
                ForEach(outputFormats) { outputFormat in
                    Button(outputFormat.name, systemImage: selectedOutputFormat == outputFormat ? "checkmark" : "") {
                        selectedOutputFormat = outputFormat
                    }
                }
            }
            
            Menu("Output format encoded  \(Text(outputFormatEncoded ? "On" : "Off").foregroundStyle(.secondary))") {
                Button("On", systemImage: outputFormatEncoded == true ? "checkmark" : "") {
                    outputFormatEncoded = true
                }
                Button("Off", systemImage: outputFormatEncoded == false ? "checkmark" : "") {
                    outputFormatEncoded = false
                }
            }
            
            Menu("Compress before uploading  \(Text(compressFactor >= 100 ? "Off" : "\(compressFactor)%").foregroundStyle(.secondary))") {
                ForEach(Array(stride(from: 10, through: 100, by: 10)), id: \.self) { compressFactor in
                    Button(compressFactor >= 100 ? "Off" : "\(compressFactor)%", systemImage: self.compressFactor == compressFactor ? "checkmark" : "") {
                        self.compressFactor = compressFactor
                    }
                }
            }
            
            Divider()
            
            Button("Preferences") {
                openWindow(id: "settings")
            }
            .keyboardShortcut(",")
            
            Button("Quit") {
                NSApplication.shared.terminate(self)
            }
            .keyboardShortcut("Q")
        }
    }
}

#Preview {
    StatusMenuView()
        .padding()
}
