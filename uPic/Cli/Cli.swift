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
        
        upload = MultiStringOption(shortFlag: "u", longFlag: "upload", required: true, helpMessage: "Path and URL of the file to upload".localized)
        output = StringOption(shortFlag: "o", longFlag: "output", helpMessage: "Output url format".localized)
        slient = BoolOption(shortFlag: "s", longFlag: "slient", helpMessage: "Turn off error message output".localized)
        help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Print this help message".localized)
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
            if decodePath.isAbsolutePath && FileManager.fileIsExists(path: decodePath) {
                allDataList.append(URL(fileURLWithPath: decodePath))
            } else if let fileUrl = URL(string: path), let data = try? Data(contentsOf: fileUrl)  {
                allDataList.append(data)
            } else {
                allDataList.append(path)
            }
        }
        
        var totalPathsCount = "Total paths count".localized
        totalPathsCount = totalPathsCount.replacingOccurrences(of: "{count}", with: "\(allDataList.count)")
        Console.write(totalPathsCount)
        
        // start upload
        Console.write("Uploading ...")
        (NSApplication.shared.delegate as? AppDelegate)?.uploadFiles(allDataList, .cli)
    }
    
    
    /// Upload progress
    /// - Parameter url: current url
    func uploadProgress(_ url: String) {
        resultUrls.append(OutputFormatModel.formatUrl(url, outputFormat: nil))
        progress += 1
        Console.write("Uploading \(progress)/\(allDataList.count)")
    }
    
    /// Upload error
    /// - Parameter errorMessage
    func uploadError(_ errorMessage: String? = nil) {
        if slient.value {
            resultUrls.append(allPathList[progress])
        } else {
            resultUrls.append(errorMessage ?? "Invalid file path".localized)
        }
        progress += 1
        Console.write("Uploading \(progress)/\(allDataList.count)")
    }
    
    
    /// all task was uploaded
    func uploadDone() {
        Console.write("Output URL:")
        
        Console.write(resultUrls.joined(separator: "\n"))
        DBManager.shared.close()
        DispatchQueue.main.async {
            DiskPermissionManager.shared.stopFullDiskAccessing()
            exit(EX_OK)
        }
    }
}
