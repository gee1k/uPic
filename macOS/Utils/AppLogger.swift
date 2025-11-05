//
//  AppLogger.swift
//  uPic
//
//  Created by Licardo on 2025/9/27.
//

import Foundation
import SimpleLogger

// MARK: - Public Logger Interface

enum AppLogger {
    static let app = UPicLogger(category: "app")
    static let settings = UPicLogger(category: "settings")
    static let host = UPicLogger(category: "host")
    static let history = UPicLogger(category: "history")
    static let urlScheme = UPicLogger(category: "urlScheme")
    static let notifications = UPicLogger(category: "notifications")
    static let uploader = UPicLogger(category: "uploader")
    static let bookmark = UPicLogger(category: "bookmark")
    static let tools = UPicLogger(category: "tools")
    static let shareExtension = UPicLogger(category: "shareExtension")
    static let actionExtension = UPicLogger(category: "actionExtension")
    static let appIntentsExtension = UPicLogger(category: "appIntentsExtension")
}

// MARK: - Log Formatter

private enum LogFormatter {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func formatLogLine(_ message: String, level: LogLevel) -> String {
        let timeString = timeFormatter.string(from: Date())
        return "[\(timeString)] [\(level.rawValue.uppercased())] \(message)"
    }

    static func currentDateKey() -> String {
        dateFormatter.string(from: Date())
    }

    static func createVersionHeader() -> String {
        let timeString = dateFormatter.string(from: Date())
        let version = Self.getAppVersion()
        let macOSVersion = ProcessInfo.processInfo.operatingSystemVersionString

        return """
        ============================================================================================================

                                            ██╗   ██╗ ██████╗  ██╗  ██████╗
                                            ██║   ██║ ██╔══██╗ ██║ ██╔════╝
                                            ██║   ██║ ██████╔╝ ██║ ██║
                                            ██║   ██║ ██╔═══╝  ██║ ██║
                                            ╚██████╔╝ ██║      ██║ ╚██████╗
                                             ╚═════╝  ╚═╝      ╚═╝  ╚═════╝

                    Date: \(timeString)  Version: \(version)  macOS: \(macOSVersion)  User: \(NSUserName())
        ============================================================================================================


        """
    }

    private static func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildNum = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        {
            return "v\(version)(\(buildNum))"
        }
        return "unknown"
    }
}

// MARK: - File Logger Manager

private final class FileLogManager {
    private lazy var logDirectory: URL? = {
        guard let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) else {
            return nil
        }
        return groupContainer.appendingPathComponent("Logs")
    }()

    func writeLog(_ logLine: String) {
        guard let logDirectory = logDirectory else { return }

        let currentDateKey = LogFormatter.currentDateKey()
        let fileName = "uPic-\(currentDateKey).log"
        let fileURL = logDirectory.appendingPathComponent(fileName)

        do {
            try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
            cleanupOldLogFiles(excluding: fileName)

            let logLineWithNewline = logLine + "\n"

            if FileManager.default.fileExists(atPath: fileURL.path) {
                try appendToExistingFile(at: fileURL, content: logLineWithNewline)
            } else {
                let versionHeader = LogFormatter.createVersionHeader()
                let fileContent = versionHeader + logLineWithNewline
                try fileContent.data(using: .utf8)?.write(to: fileURL, options: .atomic)
            }
        } catch {
            print("写入日志文件失败: \(error.localizedDescription)")
        }
    }

    private func appendToExistingFile(at url: URL, content: String) throws {
        guard let fileHandle = try? FileHandle(forWritingTo: url) else {
            try content.data(using: .utf8)?.write(to: url, options: .atomic)
            return
        }

        fileHandle.seekToEndOfFile()
        fileHandle.write(content.data(using: .utf8) ?? Data())
        fileHandle.closeFile()
    }

    private func cleanupOldLogFiles(excluding currentFileName: String) {
        guard let logDirectory = logDirectory else { return }

        do {
            let files = try FileManager.default.contentsOfDirectory(at: logDirectory, includingPropertiesForKeys: nil)

            for file in files {
                let fileName = file.lastPathComponent
                if fileName.hasPrefix("uPic-"), fileName.hasSuffix(".log"), fileName != currentFileName {
                    try FileManager.default.removeItem(at: file)
                }
            }
        } catch {
            print("清理历史日志文件失败: \(error.localizedDescription)")
        }
    }
}

// MARK: - Logger Implementation

struct UPicLogger: LoggerManagerProtocol {
    private let logger: LoggerManagerProtocol
    private static let fileManager = FileLogManager()

    init(category: String) {
        self.logger = .default(subsystem: "com.svend.uPic.macos", category: category)
    }

    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        let logLine = LogFormatter.formatLogLine(message, level: level)

        // 输出到文件
        Self.fileManager.writeLog(logLine)

        // 输出到SimpleLogger (会显示在控制台应用中)
        logger.log(logLine, level: level, file: file, function: function, line: line)
    }
}
