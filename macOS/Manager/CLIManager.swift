//
//  uPicCli.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/26.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa
import Defaults
import ArgumentParser

struct UPicCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "uPic",
        abstract: "uPic Command Line Interface"
    )

    @Option(name: .shortAndLong, help: "Path and URL of the file to upload")
    var upload: [String] = []

    @Option(name: .shortAndLong, help: "Output url format")
    var output: String?

    @Flag(name: .shortAndLong, help: "Turn off error message output")
    var silent: Bool = false
    
    mutating func validate() throws {
        if upload.isEmpty {
            throw ValidationError("Missing expected argument '--upload <upload>'")
        }
    }
}

class CLIManager {
    public static var shared = CLIManager()
    
    private var allPathList: [String] = []
    private var allDataList: [Any] = []
    private var progress: Int = 0
    
    private var resultUrls: [String] = []
    
    // Options
    private var output: String?
    private var silent: Bool = false
    
    func parseArgs() -> Bool {
        let args = CommandLine.arguments
        
        // If no arguments (other than executable), return false to allow GUI launch
        if args.count <= 1 { return false }
        
        // Check if arguments contain specific flags to identify CLI mode
        // This prevents the app from entering CLI mode when launched with system arguments (e.g. Xcode debug args)
        let hasUploadFlag = args.contains("-u") || args.contains("--upload")
        let hasHelpFlag = args.contains("-h") || args.contains("--help")
        
        if !hasUploadFlag && !hasHelpFlag {
            return false
        }
        
        do {
            let command = try UPicCLI.parse()
            self.output = command.output
            self.silent = command.silent
            self.allPathList = command.upload
            return true
        } catch {
            let message = UPicCLI.fullMessage(for: error)
            print(message)
            exit(EX_OK)
        }
    }
}

// MARK: - Upload
extension CLIManager {
    /// start upload
    func startUpload() async {
        allDataList.removeAll()
        progress = 0
        
        for path in allPathList {
            let decodePath = path.urlDecoded()
            if decodePath.isAbsolutePath && FileManager.fileIsExists(path: decodePath) {
                allDataList.append(URL(fileURLWithPath: decodePath))
            } else if let fileUrl = URL(string: path), let data = try? Data(contentsOf: fileUrl)  {
                var item = UploadItem()
                item.data = data
                item.originalFilename = fileUrl.lastPathComponent
                allDataList.append(item)
            } else {
                allDataList.append(path)
            }
        }
        
        print("Total paths count: \(allDataList.count)")
        
        if allDataList.count == 0 {
            exit(EX_OK)
        }
        
        // start upload
        print("Uploading ...")
        
        await UploadManager.shared.upload(
            items: allDataList,
            onProgress: { url in
                self.uploadProgress(url)
            },
            onError: { errorMessage in
                self.uploadError(errorMessage)
            },
            onCompletion: {
                self.uploadDone()
            }
        )
    }

    /// Upload progress
    /// - Parameter url: current url
    func uploadProgress(_ url: String) {
        let outputFormat = output?.lowercased()
        let outputUrl = formatOutput(url, format: outputFormat)
        
        resultUrls.append(outputUrl)
        progress += 1
        print("Uploading \(progress)/\(allDataList.count)")
    }

    /// Upload error
    /// - Parameter errorMessage
    func uploadError(_ errorMessage: String? = nil) {
        if silent {
            resultUrls.append(allPathList[progress])
        } else {
            resultUrls.append(errorMessage ?? "Invalid file path")
        }
        progress += 1
        print("Uploading \(progress)/\(allDataList.count)")
    }
    
    
    /// all task was uploaded
    func uploadDone() {
        print("Output URL:")
        
        print(resultUrls.joined(separator: "\n"))
        DispatchQueue.main.async {
            exit(EX_OK)
        }
    }
    
    // MARK: - Private Methods
    
    private func formatOutput(_ url: String, format: String?) -> String {
        guard let format = format else {
             return OutputFormatModel.formatUrl(url, outputFormat: nil)
        }
        
        var formatUrl = url
        if Defaults[.outputFormatEncoded] {
            formatUrl = url.urlEncoded()
        }
        
        // Filename processing
        var filename = url.lastPathComponent.deletingPathExtension.trim()
        let tempArr = filename.components(separatedBy: .whitespaces).map{ $0.trim() }.filter{ !$0.isEmpty }
        filename = tempArr.joined(separator: "")
        
        switch format {
        case "url":
            return formatUrl
        case "html":
            return "<img src='\(formatUrl)' alt='\(filename)'/>"
        case "md", "markdown":
            return "![\(filename)](\(formatUrl))"
        case "ubb":
            return "[img]\(formatUrl)[/img]"
        default:
            return OutputFormatModel.formatUrl(url, outputFormat: nil)
        }
    }
}
