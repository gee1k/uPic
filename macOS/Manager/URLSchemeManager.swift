//
//  URLSchemeManager.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/27.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SimpleLogger
import SwiftUI

class URLSchemeManager {
    @ObservedObject private var uploader = UploadeManager.shared

    static var shared = URLSchemeManager()

    func handleURL(_ urlStr: String) async {
        AppLogger.urlScheme.debug("Starting to parse URLScheme parameters: \(urlStr)")

        guard let url = NSURL(string: urlStr) else {
            AppLogger.urlScheme.error("URLScheme parameter parsing failed")
            return
        }

        // 解析出参数
        var param = urlStr
        let i = "\(url.scheme!)://".count
        param.removeFirst(i)

        AppLogger.urlScheme.debug("URLScheme parameter parsing successful: \(param)")

        /// 解析参数类型
        let keyValue = param.split(separator: "?")
        switch keyValue.first {
        case "files":
            if keyValue.count == 2 {
                let pathStr = String(keyValue.last ?? "")
                AppLogger.urlScheme.debug("URLScheme pload type file: \(pathStr)")
                await uploader.upload(fileURLs: [URL(filePath: pathStr)])
            }
        case "url":
            if keyValue.count == 2 {
                let url = String(keyValue.last ?? "")
                if let fileUrl = URL(string: url.urlDecoded()), let data = try? Data(contentsOf: fileUrl) {
                    AppLogger.urlScheme.debug("Upload type URL: \(fileUrl)")
                    await uploader.upload(fileData: data)
                }
            }
        case .some(let str) where str.contains("x-callback-url"):
            AppLogger.urlScheme.debug("URLScheme pload type: x-callback-url")

            if str.contains("acceptSnip") {
                AppLogger.urlScheme.info("Processing x-callback-url request: \(keyValue)")
                uploader.uploadFromClipboard()
            } else {
                AppLogger.urlScheme.warning("x-callback-url request error: \(keyValue)")
            }
        default:
            debugPrint(keyValue)
        }
    }
}
