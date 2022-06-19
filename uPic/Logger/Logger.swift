//
//  Logger.swift
//  uPic
//
//  Created by Svend on 2022/6/19.
//  Copyright © 2022 Svend Jin. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift


public class Logger {
    public static var shared = Logger()
    
    private var fileLogger: DDFileLogger?
    
    init() {
        
        let customFormatter = CustomDDLogFormatter()
        
        let ddosLogger = DDOSLogger.sharedInstance
        ddosLogger.logFormatter = customFormatter
        
        // Init DDLog
        DDLog.add(ddosLogger) // Uses os_log
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 100
        fileLogger.logFileManager.logFilesDiskQuota = 20 * 1024 * 1024 // 20M
        fileLogger.logFormatter = customFormatter
        DDLog.add(fileLogger)
        
        self.fileLogger = fileLogger
    }
    
    public func verbose(_ message: Any,
                        file: StaticString = #file,
                        function: StaticString = #function,
                        line: UInt = #line) {
        DDLogVerbose(message, file: file, function: function, line: line)
    }
    
    public func debug(_ message: Any,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line) {
        DDLogDebug(message, file: file, function: function, line: line)
    }
    
    public func info(_ message: Any,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
        DDLogInfo(message, file: file, function: function, line: line)
    }
    
    public func warn(_ message: Any,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
        DDLogWarn(message, file: file, function: function, line: line)
    }
    
    public func error(_ message: Any,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line) {
        DDLogError(message, file: file, function: function, line: line)
    }
    
    public var logFileDataArray: [Data] {
        get {
            guard let ddFileLogger = self.fileLogger else {
                return []
            }
            let logFilePaths = ddFileLogger.logFileManager.sortedLogFilePaths 
            var logFileDataArray = [Data]()
            for logFilePath in logFilePaths {
                
                let fileURL = URL(fileURLWithPath: logFilePath)
                if let logFileData = try? Data(contentsOf: fileURL, options: .mappedIfSafe) {
                    // Insert at front to reverse the order, so that oldest logs appear first.
                    logFileDataArray.insert(logFileData, at: 0)
                }
            }
            return logFileDataArray
        }
    }
}


class CustomDDLogFormatter: NSObject, DDLogFormatter {
    let dateFormmater = DateFormatter()
    
    public override init() {
        super.init()
        dateFormmater.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
    }
    
    public func format(message logMessage: DDLogMessage) -> String? {
        let logLevel: String
        switch logMessage.flag {
        case DDLogFlag.error:
            logLevel = "ERROR"
        case DDLogFlag.warning:
            logLevel = "WARNING"
        case DDLogFlag.info:
            logLevel = "INFO"
        case DDLogFlag.debug:
            logLevel = "DEBUG"
        default:
            logLevel = "VERBOSE"
        }
        
        let dt = dateFormmater.string(from: logMessage.timestamp)
        let logMsg = logMessage.message
        let lineNumber = logMessage.line
        let file = logMessage.fileName
        let functionName = logMessage.function
        let threadId = logMessage.threadID

        return "\(dt) [\(threadId)] [\(logLevel)] [\(file):\(lineNumber)]\(functionName ?? "") - \(logMsg)"
    }
}
