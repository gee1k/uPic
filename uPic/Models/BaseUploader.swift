//
//  BaseUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/10.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class BaseUploader {
    
    ///
    /// 作为上传的统一入口
    /// As a unified entry point for uploads
    ///
    static func upload(url: URL) {
        guard let host = ConfigManager.shared.getDefaultHost() else {
            return
        }
        
        let fileExtensions = BaseUploader.getFileExtensions()
        if (!BaseUploader.checkFileExtensions(fileExtensions: fileExtensions, fileExtension: url.pathExtension)) {
            return
        }
        
        /* 有新的图床在这里进行判断调用 */
        switch host.type {
        case .smms:
            SmmsUploader.shared.upload(url)
            break
        case .upyun_USS:
            UpYunUploader.shared.upload(url)
            break
        case .qiniu_KODO:
            QiniuUploader.shared.upload(url)
            break
        }
    }
    
    ///
    /// 作为上传的统一入口
    /// As a unified entry point for uploads
    ///
    static func upload(data: Data) {
        guard let host = ConfigManager.shared.getDefaultHost() else {
            return
        }
        
        /* 有新的图床在这里进行判断调用 */
        switch host.type {
        case .smms:
            SmmsUploader.shared.upload(data)
            break
        case .upyun_USS:
            UpYunUploader.shared.upload(data)
            break
        case .qiniu_KODO:
            QiniuUploader.shared.upload(data)
            break
        }
    }
    
    ///
    /// 获取当前图床对应的支持文件格式
    ///
    static func getFileExtensions() -> [String] {
        guard let host = ConfigManager.shared.getDefaultHost() else {
            return [String]()
        }
        
        /* 有新的图床在这里进行判断调用 */
        switch host.type {
        case .smms:
            return SmmsUploader.fileExtensions
        case .upyun_USS:
            return UpYunUploader.fileExtensions
        case .qiniu_KODO:
            return QiniuUploader.fileExtensions
        }
    }
    
    private static func checkFileExtensions(fileExtensions: [String], fileExtension: String) -> Bool {
        if fileExtensions.count == 0 {
            return true
        }
        let valid = fileExtensions.contains(fileExtension.lowercased())
        if !valid {
            (NSApplication.shared.delegate as? AppDelegate)?.uploadFaild(errorMsg: NSLocalizedString("file-format-is-not-supported", comment: "文件格式不支持"))
        }
        return valid
    }
    
    func start() {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadStart()
    }
    
    func progress(percent: Double) {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadProgress(percent: percent)
    }
    
    func completed(url: String) {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadCompleted(url: url)
    }
    
    func faild(errorMsg: String? = "") {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadFaild(errorMsg: errorMsg)
    }
}
