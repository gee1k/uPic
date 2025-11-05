//
//  ActionRequestHandler.swift
//  uPicActionExtension
//
//  Created by Licardo on 2025/11/5.
//

import AppKit
import Foundation
import SimpleLogger
import UniformTypeIdentifiers

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        processSelectedFiles(context: context) { filePaths in
            DispatchQueue.main.async {
                if !filePaths.isEmpty {
                    // 将文件路径编码并通过 URL Scheme 传递给主应用
                    let encodedPaths = filePaths.compactMap { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }
                    let pathsParam = encodedPaths.joined(separator: ",")
                    let encodeUrl = "uPic://files?\(pathsParam)"

                    if let url = URL(string: encodeUrl) {
                        NSWorkspace.shared.open(url)
                        AppLogger.actionExtension.info("Call the main application and pass the file path: \(filePaths)")
                    }
                } else {
                    AppLogger.actionExtension.warning("No valid files found to process")
                }

                // 完成扩展请求
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
                    context.cancelRequest(withError: cancelError)
                }
            }
        }
    }

    private func processSelectedFiles(context: NSExtensionContext, completion: @escaping ([String]) -> Void) {
        guard let inputItem = context.inputItems.first as? NSExtensionItem, let inputAttachments = inputItem.attachments else {
            AppLogger.actionExtension.warning("No input items or attachments found")
            completion([])
            return
        }

        var filePaths: [String] = []
        var processedCount = 0
        let totalCount = inputAttachments.count

        AppLogger.actionExtension.info("Processing \(totalCount) attachments")

        for attachment in inputAttachments {
            // 尝试获取第一个可用的类型标识符
            guard let typeIdentifier = attachment.registeredTypeIdentifiers.first else {
                defer {
                    processedCount += 1
                    if processedCount == totalCount {
                        completion(filePaths)
                    }
                }
                return
            }

            attachment.loadItem(forTypeIdentifier: typeIdentifier) { data, error in
                defer {
                    processedCount += 1
                    if processedCount == totalCount {
                        completion(filePaths)
                    }
                }

                if let error = error {
                    AppLogger.actionExtension.error("Failed to load generic attachment: \(error.localizedDescription)")
                    return
                }

                if let url = data as? URL {
                    let filePath = url.path
                    filePaths.append(filePath)
                    AppLogger.actionExtension.info("Successfully processed generic file: \(filePath)")
                } else {
                    AppLogger.shareExtension.error("Unable to parse file URL")
                }
            }
        }
    }
}
