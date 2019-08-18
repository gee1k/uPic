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
            (NSApplication.shared.delegate as? AppDelegate)?.uploadFaild(errorMsg: NSLocalizedString("file-format-is-not-supported", comment: "文件格式不支持"))
            return
        }
        
        if let attr = try? FileManager.default.attributesOfItem(atPath: url.path), let fileSize = attr[FileAttributeKey.size] as? UInt64 {
            let limitSize = BaseUploader.getFileSizeLimit()
            if (!BaseUploader.checkFileSize(fileSize: fileSize, limitSize: limitSize)) {
                
                let errorMsg = "\(NSLocalizedString("file-is-over-the-size-limit", comment: "文件大小超过限制"))\(ByteCountFormatter.string(fromByteCount: Int64(limitSize), countStyle: .binary))"
                (NSApplication.shared.delegate as? AppDelegate)?.uploadFaild(errorMsg: errorMsg)
                return
            }
        }

        /* 有新的图床在这里进行判断调用 */
        switch host.type {
        case .smms:
            SmmsUploader.shared.upload(url)
            break
        case .custom:
            CustomUploader.shared.upload(url)
            break
        case .upyun_USS:
            UpYunUploader.shared.upload(url)
            break
        case .qiniu_KODO:
            QiniuUploader.shared.upload(url)
            break
        case .aliyun_OSS:
            AliyunUploader.shared.upload(url)
            break
        case .tencent_COS:
            TencentUploader.shared.upload(url)
            break
        case .github:
            GithubUploader.shared.upload(url)
            break
        case .gitee:
            GiteeUploader.shared.upload(url)
            break
        case .weibo:
            WeiboUploader.shared.upload(url)
            break
        case .amazon_S3:
            AmazonS3Uploader.shared.upload(url)
            break
        case .imgur:
            ImgurUploader.shared.upload(url)
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
        
        let limitSize = BaseUploader.getFileSizeLimit()
        if (!BaseUploader.checkFileSize(fileSize: UInt64(data.count), limitSize: limitSize)) {
            
            let errorMsg = "\(NSLocalizedString("file-is-over-the-size-limit", comment: "文件大小超过限制"))\(ByteCountFormatter.string(fromByteCount: Int64(limitSize), countStyle: .binary))"
            (NSApplication.shared.delegate as? AppDelegate)?.uploadFaild(errorMsg: errorMsg)
            return
        }

        /* 有新的图床在这里进行判断调用 */
        switch host.type {
        case .smms:
            SmmsUploader.shared.upload(data)
            break
        case .custom:
            CustomUploader.shared.upload(data)
            break
        case .upyun_USS:
            UpYunUploader.shared.upload(data)
            break
        case .qiniu_KODO:
            QiniuUploader.shared.upload(data)
            break
        case .aliyun_OSS:
            AliyunUploader.shared.upload(data)
            break
        case .tencent_COS:
            TencentUploader.shared.upload(data)
            break
        case .github:
            GithubUploader.shared.upload(data)
            break
        case .gitee:
            GiteeUploader.shared.upload(data)
            break
        case .weibo:
            WeiboUploader.shared.upload(data)
            break
        case .amazon_S3:
            AmazonS3Uploader.shared.upload(data)
            break
        case .imgur:
            ImgurUploader.shared.upload(data)
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
        case .custom:
            return CustomUploader.fileExtensions
        case .upyun_USS:
            return UpYunUploader.fileExtensions
        case .qiniu_KODO:
            return QiniuUploader.fileExtensions
        case .aliyun_OSS:
            return AliyunUploader.fileExtensions
        case .tencent_COS:
            return TencentUploader.fileExtensions
        case .github:
            return GithubUploader.fileExtensions
        case .gitee:
            return GiteeUploader.fileExtensions
        case .weibo:
            return WeiboUploader.fileExtensions
        case .amazon_S3:
            return AmazonS3Uploader.fileExtensions
        case .imgur:
            return ImgurUploader.fileExtensions
        }
    }
    
    ///
    /// 获取当前图床对应的文件大小限制
    ///
    static func getFileSizeLimit() -> UInt64 {
        guard let host = ConfigManager.shared.getDefaultHost() else {
            return 0
        }
        
        /* 有新的图床在这里进行判断调用 */
        switch host.type {
        case .smms:
            return SmmsUploader.limitSize
        case .imgur:
            return ImgurUploader.limitSize
        default:
            return 0
        }
    }

    private static func checkFileExtensions(fileExtensions: [String], fileExtension: String) -> Bool {
        if fileExtensions.count == 0 {
            return true
        }
        let valid = fileExtensions.contains(fileExtension.lowercased())
        return valid
    }
    
    private static func checkFileSize(fileSize: UInt64?, limitSize: UInt64) -> Bool {
        guard let size = fileSize else {
            return true
        }
        
        if (limitSize <= 0) {
            return true
        }
        
        return size <= limitSize
    }

    func start() {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadStart()
    }

    func progress(percent: Double) {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadProgress(percent: percent)
    }

    func completed(url: String) {
        ConfigManager.shared.addHistory(url: url)
        (NSApplication.shared.delegate as? AppDelegate)?.uploadCompleted(url: url)
    }

    func faild(errorMsg: String? = "") {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadFaild(errorMsg: errorMsg)
    }
}
