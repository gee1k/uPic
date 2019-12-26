//
//  uPicCli.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/26.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa

enum UploadSourceType {
    case normal
    case cli
}

class Cli {
    public static var shared = Cli()
    
    private var cliKit: CommandLineKit!
    private var upload: MultiStringOption!
    public var output: StringOption!
    
    private var validPathList: [Any] = []
    private var progress: Int = 0
    
    func handleCommandLine() -> Bool {
        // handle arguments
        let arguments = ProcessInfo.processInfo.arguments.dropFirst()
        guard arguments.count > 0 else { return false }
        
        var args: [String] = []
        var dropNextArg = false

        for arg in arguments {
          if dropNextArg {
            dropNextArg = false
            continue
          }
          if arg.hasPrefix("-NS") {
            dropNextArg = true
          } else {
            args.append(arg)
          }
        }
        
        guard args.count > 0 else { return false }
        
        validPathList = []
        
        cliKit = CommandLineKit(arguments: args)
        // cliKit = CommandLineKit(arguments: ["uPic", "-u", "/Users/svend/Desktop/uPicv0.15.3.png", "/Users/svend/Desktop/uPicv0.15.3%202.png", "/Users/svend/Desktop", "http://qiniu.svend.cc/uPic/2019%2012%2026g8WCtu.png", "-o", "md"])
        
        upload = MultiStringOption(shortFlag: "u", longFlag: "upload", required: true, helpMessage: "Path and URL of the file to upload".localized)
        output = StringOption(shortFlag: "o", longFlag: "output", helpMessage: "Output url format".localized)
        let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message".localized)
        cliKit.addOptions(upload, output, help)
        do {
          try cliKit.parse()
        } catch {
          cliKit.printUsage(error)
          exit(EX_USAGE)
        }
        
        if let paths = upload.value {
            startUpload(paths)
        }
        
        return true
    }
    
}

// MARK: - Upload
extension Cli {
    /// start upload
    /// - Parameter paths: file paths or URLs
    private func startUpload(_ paths: [String]) {
        
        // invalid paths
        var invalidPathList: [String] = []
        
        for path in paths {
            let decodePath = path.urlDecoded()
            if decodePath.isAbsolutePath && FileManager.fileIsExists(path: decodePath) {
                validPathList.append(URL(fileURLWithPath: decodePath))
            } else if let fileUrl = URL(string: path), let data = try? Data(contentsOf: fileUrl)  {
                validPathList.append(data)
            } else {
                invalidPathList.append(path)
            }
        }
        
        // has invalid paths
        if invalidPathList.count > 0 {
            var illegalLog = "Found illegal paths or URLs".localized
            illegalLog = illegalLog.replacingOccurrences(of: "{count}", with: "\(invalidPathList.count)")
            Console.write(illegalLog)
        }
        
        // no valid paths
        if validPathList.count == 0 {
            Console.write("No legal path or URL".localized)
            exit(EX_DATAERR)
        }
        
        // has valid paths
        var legalLog = "Legal paths or URLs".localized
        legalLog = legalLog.replacingOccurrences(of: "{count}", with: "\(validPathList.count)")
        Console.write(legalLog)
        
        // start upload
        Console.write("Uploading ...")
        (NSApplication.shared.delegate as? AppDelegate)?.uploadFiles(validPathList, .cli)
    }
    
    
    /// Upload progress
    /// - Parameter url: current url
    func uploadProgress(_ url: String) {
        progress += 1
        Console.write("Uploading \(progress)/\(validPathList.count)")
    }
    
    
    /// all task was uploaded
    /// - Parameter urls: all urls
    func uploadDone(_ urls: [String]) {
        Console.write("Output URL:")
        
        let outputType = OutputType(value: output?.value)
        
        let outputUrls = urls.map{ outputType.formatUrl($0) }
        
        Console.write(outputUrls.joined(separator: "\n"))

        exit(EX_OK)
    }
}
