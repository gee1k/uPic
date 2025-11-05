//
//  ShareViewController.swift
//  uPicShareExtension
//
//  Created by Licardo on 2025/11/3.
//

import Cocoa
import SimpleLogger
import UniformTypeIdentifiers

class ShareViewController: NSViewController {
    override func loadView() {
        super.loadView()
        self.view = NSView()
        self.view.frame = NSRect(x: 0, y: 0, width: 0, height: 0)

        self.processSelectedFiles(context: self.extensionContext!) { filePaths in
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
                } else {
                    AppLogger.shareExtension.warning("No valid files found to process")
                }

                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
                    self.extensionContext!.cancelRequest(withError: cancelError)
                }
            }
        }
    }

    private func processSelectedFiles(context: NSExtensionContext, completion: @escaping ([String]) -> Void) {
        guard let inputItem = context.inputItems.first as? NSExtensionItem, let inputAttachments = inputItem.attachments else {
            AppLogger.shareExtension.warning("No input items or attachments found")
            completion([])
            return
        }

        var filePaths: [String] = []
        var processedCount = 0
        let totalCount = inputAttachments.count

        AppLogger.shareExtension.info("Processing \(totalCount) attachments")

        for attachment in inputAttachments {
            guard attachment.hasItemConformingToTypeIdentifier("public.url") else {
                defer {
                    processedCount += 1
                    if processedCount == totalCount {
                        completion(filePaths)
                    }
                }
                return
            }

            attachment.loadItem(forTypeIdentifier: "public.url") { data, error in
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

                if let data = data as? Data, let url = NSURL(dataRepresentation: data, relativeTo: nil) as URL? {
                    let filePath = url.path
                    filePaths.append(filePath)
                    AppLogger.actionExtension.info("Successfully processed file: \(filePath)")
                } else {
                    AppLogger.shareExtension.error("Unable to parse file URL")
                }
            }
        }
    }
}
