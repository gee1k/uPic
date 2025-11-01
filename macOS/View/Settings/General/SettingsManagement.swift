//
//  SettingsManagement.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/7.
//

import Defaults
import KeyboardShortcuts
import SimpleLogger
import SwiftUI
import UniformTypeIdentifiers

struct SettingsManagement: View {
    // Export/Import states
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var importURL: URL?
    @State private var showExportAlert = false
    @State private var showImportAlert = false
    @State private var showResetAlert = false
    @State private var alertMessage = ""

    // Log export states
    @State private var isExportingLogs = false
    @State private var logContent: String = ""

    var body: some View {
        Section {
            HStack(alignment: .top) {
                Label("Logs", systemImage: "doc.text")

                Spacer()

                Button {
                    exportLogs()
                } label: {
                    Label("Export Logs", systemImage: "square.and.arrow.up")
                }
            }

            HStack {
                Spacer()
                Button {
                    showResetAlert = true
                } label: {
                    Label("Reset all settings", systemImage: "arrow.clockwise")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Settings Management")
        }
        .fileExporter(
            isPresented: $isExportingLogs,
            document: LogDocument(text: logContent),
            contentType: .text,
            defaultFilename: "uPic.log"
        ) { result in
            switch result {
            case .success(let url):
                AppLogger.settings.info("Logs file successfully exported to: \(url.path)")
                alertMessage = String(localized: "Logs file successfully exported to: \(url.lastPathComponent)")
                showExportAlert = true
            case .failure(let error):
                AppLogger.settings.error("Logs file export failed: \(error.localizedDescription)")
                alertMessage = String(localized: "Logs file export failed: \(error.localizedDescription)")
                showExportAlert = true
            }
        }
        .fileDialogDefaultDirectory(URL(fileURLWithPath: "/Users/\(NSUserName())/Downloads"))
        .alert("Reset All Settings", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                AppLogger.settings.warning("User initiated reset of all settings")
                if let userDefaults = UserDefaults(suiteName: Constants.appGroupIdentifier) {
                    Defaults.removeAll(suite: userDefaults)
                }
                KeyboardShortcuts.resetAll()
                AppLogger.settings.info("All settings have been successfully reset")
            }
        } message: {
            Text("Are you sure you want to reset all settings? This action cannot be undone and will remove all your custom menu items and preferences.")
        }
    }

    private func exportLogs() {
        guard let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) else {
            alertMessage = String(localized: "Unable to access logs directory.")
            AppLogger.settings.info("Unable to access logs directory.")
            showExportAlert = true
            return
        }

        let logsDirectory = groupContainer.appendingPathComponent("Logs")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        let logFileName = "uPic-\(today).log"
        let logFileURL = logsDirectory.appendingPathComponent(logFileName)
        AppLogger.settings.info("Starting export of log file: \(logFileURL.path(percentEncoded: false))")

        do {
            let content = try String(contentsOf: logFileURL, encoding: .utf8)
            logContent = content
            isExportingLogs = true
        } catch {
            AppLogger.settings.error("Log export failed: \(error.localizedDescription)")
            alertMessage = String(localized: "Logs file export failed: \(error.localizedDescription)")
            showExportAlert = true
        }
    }
}

struct LogDocument: FileDocument {
    let text: String

    init(text: String) {
        self.text = text
    }

    static var readableContentTypes: [UTType] { [.text] }

    init(configuration: ReadConfiguration) throws {
        self.text = ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: text.data(using: .utf8) ?? Data())
    }
}

#Preview {
    SettingsManagement()
}
