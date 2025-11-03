//
//  ShareViewController.swift
//  uPicShareExtension
//
//  Created by Licardo on 2025/11/3.
//

import Cocoa
import SimpleLogger

class ShareViewController: NSViewController {
    override func loadView() {
        super.loadView()
        self.view = NSView()
        self.view.frame = NSRect(x: 0, y: 0, width: 0, height: 0)

        self.processSelectedFiles { filePaths in
            DispatchQueue.main.async {
                if !filePaths.isEmpty {
                    // 将文件路径编码并通过 URL Scheme 传递给主应用
                    let encodedPaths = filePaths.compactMap { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }
                    let pathsParam = encodedPaths.joined(separator: ",")
                    let encodeUrl = "uPic://files?\(pathsParam)"
                    
                    if let url = URL(string: encodeUrl) {
                        NSWorkspace.shared.open(url)
                        AppLogger.shareExtension.info("Call the main application and pass the file path: \(filePaths)")
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
                    self.extensionContext!.cancelRequest(withError: cancelError)
                }
            }
        }
    }

    private func processSelectedFiles(completion: @escaping ([String]) -> Void) {
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        var filePaths: [String] = []
        var processedCount = 0
        
        guard let itemProviders = item.attachments, !itemProviders.isEmpty else {
            completion([])
            return
        }
        
        let totalCount = itemProviders.count
        
        for itemProvider in itemProviders {
            if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                itemProvider.loadItem(forTypeIdentifier: "public.url") { data, error in
                    defer {
                        processedCount += 1
                        if processedCount == totalCount {
                            // 所有文件处理完成，返回文件路径数组
                            completion(filePaths)
                        }
                    }
                    
                    if let error = error {
                        AppLogger.shareExtension.error("Failed to load file: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let nsData = data as? NSData, let originalURL = NSURL(dataRepresentation: nsData as Data, relativeTo: nil) as URL? else {
                        AppLogger.shareExtension.error("Unable to parse file URL")
                        return
                    }
                    
                    // 直接获取原始文件路径，不再复制文件
                    let filePath = originalURL.path
                    filePaths.append(filePath)
                    AppLogger.shareExtension.error("File path obtained: \(filePath)")
                }
            } else {
                processedCount += 1
                if processedCount == totalCount {
                    completion(filePaths)
                }
            }
        }
    }
}
