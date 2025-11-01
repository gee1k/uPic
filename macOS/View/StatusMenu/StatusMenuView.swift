//
//  StatusMenuView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import Defaults
import KeyboardShortcuts
import SwiftData
import SwiftUI
import UPicCore

struct StatusMenuView: View {
    @Default(.selectedHostId) var selectedHostId
    @Default(.screenshotApp) var screenshotApp
    @Default(.selectedOutputFormat) var selectedOutputFormat
    @Default(.outputFormats) var outputFormats
    @Default(.outputFormatEncoded) var outputFormatEncoded
    @Default(.compressFactor) var compressFactor
    @Default(.autoCopyUrlToClipboard) var autoCopyUrlToClipboard

    @ObservedObject private var uploader = UploadeManager.shared

    @Query private var hostModels: [HostModel]
    @Query(sort: \UploadHistoryModel.createdDate, order: .reverse) private var uploadHistory: [UploadHistoryModel]

    @Environment(\.openWindow) var openWindow

    private var selectedHostName: String {
        if let hostModel = hostModels.first(where: { $0.id == selectedHostId }) {
            return hostModel.name
        } else {
            return ""
        }
    }
    
    var body: some View {
        VStack {
            if uploader.isUploading {
                Button("Cancel upload") {
                    uploader.cancelAllUploads()
                }
                Divider()
            }
            
            Button("Upload from select file") {
                uploader.uploadFromSelectFile()
            }
            .globalKeyboardShortcut(.uploadFromSelectFile)
            .onGlobalKeyboardShortcut(.uploadFromSelectFile, type: .keyUp) {
                uploader.uploadFromSelectFile()
            }
            
            Button("Upload from clipboard") {
                uploader.uploadFromClipboard()
            }
            .globalKeyboardShortcut(.uploadFromClipboard)
            .onGlobalKeyboardShortcut(.uploadFromClipboard, type: .keyUp) {
                uploader.uploadFromClipboard()
            }
            
            Menu("Upload from screenshot  \(Text(screenshotApp.displayName).foregroundStyle(.secondary))") {
                ForEach(ScreenshotApp.allCases, id: \.self) { screenshotApp in
                    Button {
                        self.screenshotApp = screenshotApp
                    } label: {
                        Label {
                            Text("\(screenshotApp.displayName) \(self.screenshotApp == screenshotApp ? "✓" : "")")
                        } icon: {
                            screenshotApp.icon
                        }
                    }
                }
            } primaryAction: {
                uploader.uploadFromScreenshot()
            }
            .globalKeyboardShortcut(.uploadFromScreenshot)
            .onGlobalKeyboardShortcut(.uploadFromScreenshot, type: .keyUp) {
                uploader.uploadFromScreenshot()
            }
    
            Menu("Host  \(Text(selectedHostName).foregroundStyle(.secondary))") {
                if hostModels.isEmpty {
                    Text("No host yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(hostModels) { hostModel in
                        Button {
                            selectedHostId = hostModel.id
                        } label: {
                            Label {
                                Text("\(hostModel.name) \(selectedHostId == hostModel.id ? "✓" : "")")
                            } icon: {
                                Image("host_icon_\(hostModel.typeRaw ?? "smms")")
                            }
                        }
                    }
                }
             }
            
            Menu("Output format  \(Text(selectedOutputFormat.name).foregroundStyle(.secondary))") {
                ForEach(outputFormats) { outputFormat in
                    Button {
                        selectedOutputFormat = outputFormat
                    } label: {
                        HStack {
                            if selectedOutputFormat == outputFormat {
                                Image(systemName: "checkmark")
                            }
                            Text(outputFormat.name)
                        }
                    }
                }
            }
            
            Menu("Output format encoded  \(Text(outputFormatEncoded ? "Enabled" : "Disabled").foregroundStyle(.secondary))") {
                Button {
                    outputFormatEncoded = true
                } label: {
                    HStack {
                        if outputFormatEncoded == true {
                            Image(systemName: "checkmark")
                        }
                        Text("Enabled")
                    }
                }
                
                Button {
                    outputFormatEncoded = false
                } label: {
                    HStack {
                        if outputFormatEncoded == false {
                            Image(systemName: "checkmark")
                        }
                        Text("Disabled")
                    }
                }
            }
            
            Menu("Compress before uploading  \(Text(compressFactor >= 100 ? "Disabled" : "\(compressFactor)%").foregroundStyle(.secondary))") {
                ForEach(Array(stride(from: 10, through: 100, by: 10)), id: \.self) { compressFactor in
                    Button {
                        self.compressFactor = compressFactor
                    } label: {
                        HStack {
                            if self.compressFactor == compressFactor {
                                Image(systemName: "checkmark")
                            }
                            Text(compressFactor >= 100 ? "Disabled" : "\(compressFactor)%")
                        }
                    }
                }
            }
            
            Menu("Auto clipboard  \(Text(autoCopyUrlToClipboard ? "Enabled" : "Disabled").foregroundStyle(.secondary))") {
                Button {
                    autoCopyUrlToClipboard = true
                } label: {
                    HStack {
                        if autoCopyUrlToClipboard == true {
                            Image(systemName: "checkmark")
                        }
                        Text("Enabled")
                    }
                }
                
                Button {
                    autoCopyUrlToClipboard = false
                } label: {
                    HStack {
                        if autoCopyUrlToClipboard == false {
                            Image(systemName: "checkmark")
                        }
                        Text("Disabled")
                    }
                }
            }
            
            Divider()
            
            Menu("History") {
                if uploadHistory.isEmpty {
                    Text("No history yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(uploadHistory.prefix(8)), id: \.id) { history in
                        HistoryMenuItem(history: history)
                    }

                    Divider()

                    Button("View More...") {
                        NSApp.activate(ignoringOtherApps: true)
                        openWindow(id: "database")
                    }
                }
            }
            
            Button("Database") {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "database")
            }
            .keyboardShortcut("D")
            
            Divider()
            
            Button("Preferences") {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "settings")
            }
            .keyboardShortcut(",")
            
            Divider()
            
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
