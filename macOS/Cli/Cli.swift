//
//  uPicCli.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/26.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Defaults
import Foundation

enum UploadSourceType {
    case normal
    case cli
}

class Cli {
    static var shared = Cli()
    
    private var cliKit: CommandLineKit!
    private var upload: MultiStringOption!
    private var output: StringOption!
    private var slient: BoolOption!
    private var help: BoolOption!
    
    private var allPathList: [String] = []
    private var allDataList: [Any] = []
    private var progress: Int = 0
    
    private var resultUrls: [String] = []
    
    func getFilePaths() -> [String]? {
        let arguments = CommandLine.arguments
        guard arguments.count > 1 else { return nil }
        
        cliKit = CommandLineKit(arguments: arguments)
        
        allPathList = []
        allDataList = []
        resultUrls = []
        
        upload = MultiStringOption(shortFlag: "u", longFlag: "upload", required: true, helpMessage: String(localized: "Path and URL of the file to upload"))
        output = StringOption(shortFlag: "o", longFlag: "output", helpMessage: String(localized: "Output url format"))
        slient = BoolOption(shortFlag: "s", longFlag: "slient", helpMessage: String(localized: "Turn off error message output"))
        help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: String(localized: "Print this help message"))
        cliKit.addOptions(upload, output, slient, help)
        do {
            try cliKit.parse()
        } catch {
            cliKit.printUsage(error)
            return nil
        }
        
        guard let paths = upload.value else {
            cliKit.printUsage()
            return nil
        }
        return paths
    }
}

// MARK: - Upload

extension Cli {
    /// start upload
    /// - Parameter paths: file paths or URLs
    func startUpload(_ paths: [String]) {
        allPathList = paths
        
        for path in paths {
            let decodePath = path.urlDecoded()
            if decodePath.isAbsolutePath, FileManager.fileIsExists(path: decodePath) {
                allDataList.append(URL(fileURLWithPath: decodePath))
            } else if let fileUrl = URL(string: path), let data = try? Data(contentsOf: fileUrl) {
                allDataList.append(data)
            } else {
                allDataList.append(path)
            }
        }
        
        var totalPathsCount = String(localized: "Total paths count")
        totalPathsCount = totalPathsCount.replacingOccurrences(of: "{count}", with: "\(allDataList.count)")
        Console.write(totalPathsCount)
        
        // start upload
        Console.write(String(localized: "Uploading..."))
        
        if let urls = allDataList as? [URL] {
            Task {
                await UploadeManager.shared.upload(fileURLs: urls)
            }
        }
    }
    
    /// Upload progress
    /// - Parameter url: current url
    func uploadProgress(_ url: String) {
        var outputUrl = ""
        if let output = output?.value?.lowercased() {
            var formatUrl = url
            if Defaults[.outputFormatEncoded] {
                formatUrl = url.urlEncoded()
            }
            var filename = url.lastPathComponent.deletingPathExtension.trim()
            let tempArr = filename.components(separatedBy: .whitespaces).map { $0.trim() }.filter { !$0.isEmpty }
            filename = tempArr.joined(separator: "")
            switch output {
            case "url":
                outputUrl = formatUrl
            case "html":
                outputUrl = "<img src='\(formatUrl)' alt='\(filename)'/>"
            case "md":
                outputUrl = "![\(filename)](\(formatUrl))"
            case "markdown":
                outputUrl = "![\(filename)](\(formatUrl))"
            case "ubb":
                outputUrl = "[img]\(formatUrl)[/img]"
            default:
                outputUrl = OutputFormatModel.formatUrl(url, outputFormat: nil)
            }
        } else {
            outputUrl = OutputFormatModel.formatUrl(url, outputFormat: nil)
        }
        
        resultUrls.append(outputUrl)
        progress += 1
        Console.write(String(localized: "Uploading \(progress)/\(allDataList.count)"))
    }
    
    /// Upload error
    /// - Parameter errorMessage
    func uploadError(_ errorMessage: String? = nil) {
        if slient.value {
            resultUrls.append(allPathList[progress])
        } else {
            resultUrls.append(errorMessage ?? String(localized: "Invalid file path"))
        }
        progress += 1
        Console.write(String(localized: "Uploading \(progress)/\(allDataList.count)"))
    }
    
    /// all task was uploaded
    func uploadDone() {
        Console.write(String(localized: "Output URL:"))
        
        Console.write(resultUrls.joined(separator: "\n"))
        DispatchQueue.main.async {
            exit(EX_OK)
        }
    }
}
