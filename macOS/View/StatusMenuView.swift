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
    @Default(.isUploading) var isUploading
    @Default(.selectedHostId) var selectedHostId
    @Default(.screenshotApp) var screenshotApp
    @Default(.selectedOutputFormat) var selectedOutputFormat
    @Default(.outputFormats) var outputFormats
    @Default(.outputFormatEncoded) var outputFormatEncoded
    @Default(.compressFactor) var compressFactor
    
    @StateObject private var uploader: UPicUploader
    
    @Query private var hostModels: [HostModel]
    
    @Environment(\.openWindow) var openWindow
    
    init() {
        let context = ModelContext(try! ModelContainer(for: HostModel.self, UploadHistoryModel.self))
        self._uploader = StateObject(wrappedValue: UPicUploader(modelContext: context))
    }
    
    private var selectedHostName: String {
        if let hostModel = hostModels.first(where: { $0.id == selectedHostId }) {
            return hostModel.name
        } else {
            return ""
        }
    }
    
    var body: some View {
        VStack {
            if isUploading {
                Button("Cancel upload") {
                    print("取消上传")
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
            
            Button("Upload from screenshot  \(Text(screenshotApp.displayName).foregroundStyle(.secondary))") {
                uploader.uploadFromScreenshot()
            }
            .globalKeyboardShortcut(.uploadFromScreenshot)
            .onGlobalKeyboardShortcut(.uploadFromScreenshot, type: .keyUp) {
                uploader.uploadFromScreenshot()
            }
    
            Menu("Host  \(Text(selectedHostName).foregroundStyle(.secondary))") {
                ForEach(hostModels) { hostModel in
                    Button {
                        selectedHostId = hostModel.id
                    } label: {
                        Label {
                            Text("\(hostModel.name ?? "Unknown") \(selectedHostId == hostModel.id ? "✓" : "")")
                        } icon: {
                            Image("host_icon_\(hostModel.typeRaw ?? "smms")")
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
            
            Menu("Output format encoded  \(Text(outputFormatEncoded ? "On" : "Off").foregroundStyle(.secondary))") {
                Button {
                    outputFormatEncoded = true
                } label: {
                    HStack {
                        if outputFormatEncoded == true {
                            Image(systemName: "checkmark")
                        }
                        Text("On")
                    }
                }
                
                Button {
                    outputFormatEncoded = false
                } label: {
                    HStack {
                        if outputFormatEncoded == false {
                            Image(systemName: "checkmark")
                        }
                        Text("Off")
                    }
                }
            }
            
            Menu("Compress before uploading  \(Text(compressFactor >= 100 ? "Off" : "\(compressFactor)%").foregroundStyle(.secondary))") {
                ForEach(Array(stride(from: 10, through: 100, by: 10)), id: \.self) { compressFactor in
                    Button {
                        self.compressFactor = compressFactor
                    } label: {
                        HStack {
                            if self.compressFactor == compressFactor {
                                Image(systemName: "checkmark")
                            }
                            Text(compressFactor >= 100 ? "Off " : "\(compressFactor)%")
                        }
                    }
                }
            }
            
            Divider()
            
            Button("Database") {
                openWindow(id: "database")
            }
            .keyboardShortcut("D")
            
            Button("Preferences") {
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
