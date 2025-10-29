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
    @ObservedObject private var uploader = UPicUploader.shared

    static var shared = URLSchemeManager()

    func handleURL(_ urlStr: String) async {
        AppLogger.urlScheme.info("开始解析 URLScheme 参数: \(urlStr)")

        guard let url = NSURL(string: urlStr) else {
            AppLogger.urlScheme.error("URLScheme 参数解析失败")
            return
        }

        // 解析出参数
        var param = urlStr
        let i = "\(url.scheme!)://".count
        param.removeFirst(i)

        AppLogger.urlScheme.info("URLScheme 参数解析成功: \(param)")

        /// 解析参数类型
        let keyValue = param.split(separator: "?")
        switch keyValue.first {
        case "files":
            AppLogger.urlScheme.info("上传类型为: 文件")
            if keyValue.count == 2 {
                let pathStr = String(keyValue.last ?? "")
                await uploader.upload(fileURLs: [URL(filePath: pathStr)])
            }
        case "url":
            AppLogger.urlScheme.info("上传类型为: URL")
            if keyValue.count == 2 {
                let url = String(keyValue.last ?? "")
                if let fileUrl = URL(string: url.urlDecoded()), let data = try? Data(contentsOf: fileUrl) {
                    await uploader.upload(fileData: data)
                }
            }
        case .some(let str) where str.contains("x-callback-url"):
            AppLogger.urlScheme.info("上传类型为: x-callback-url")

            if str.contains("acceptSnip") {
                AppLogger.urlScheme.info("开始处理 x-callback-url 请求: \(keyValue)")
                // (NSApplication.shared.delegate as? AppDelegate)?.uploadByPasteboard()
            } else {
                AppLogger.urlScheme.warning("x-callback-url 请求错误: \(keyValue)")
            }
        default:
            debugPrint(keyValue)
        }
    }
}
