//
//  BaseUploader.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/10.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import Alamofire

class BaseUploader {

    func start() {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadStart()
    }

    func progress(percent: Double) {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadProgress(percent: percent)
    }

    func completed(url: String, _ fileData: Data?, _ fileUrl: URL?, _ fileName: String?) {
        if !url.isEmpty {
            
            var thumbnailFileData: Data!
            
            if let fileData = fileData {
                thumbnailFileData = fileData
            } else if let fileUrl = fileUrl {
                do { thumbnailFileData = try Data(contentsOf: fileUrl) } catch { }
            }
            
            if thumbnailFileData == nil {
                return
            }

            var thumbnailData: Data?
            var previewWidth: CGFloat = 0
            var previewHeight: CGFloat = 0
            let bigSize: CGSize = CGSize(width: 450, height: 600)
            var isImage: Bool = false
            if let image = NSImage(data: thumbnailFileData) {
                previewWidth = image.size.width
                previewHeight = image.size.height
                let originalScale: CGFloat = previewWidth / previewHeight
                if previewWidth > bigSize.width {
                    previewWidth = bigSize.width
                    previewHeight = previewWidth / originalScale
                }
                
                if previewHeight > bigSize.height {
                    previewHeight = bigSize.height
                    previewWidth = bigSize.height * originalScale
                }
                
                let imageSize = NSSize(width: PreviewDefaulWidthGlobal, height: PreviewDefaulWidthGlobal / originalScale)
                if let imgData = image.resizeImage(size: imageSize).tiffRepresentation,let imgRep = NSBitmapImageRep(data: imgData), let pingy = imgRep.representation(using: .png, properties:  [:]) {
                    
                    thumbnailData = BaseUploaderUtil.compressPng(pingy, factor: 5)
                } else {
                    thumbnailData = image.resizeImage(size: imageSize).tiffRepresentation
                }
                isImage = true
            }
            
            let previewModel = HistoryThumbnailModel()
            previewModel.url = url
            previewModel.previewWidth = Double(previewWidth)
            previewModel.previewHeight = Double(previewHeight)
            previewModel.thumbnailData = thumbnailData
            previewModel.isImage = isImage
            
            ConfigManager.shared.addHistory(previewModel)
        }
        (NSApplication.shared.delegate as? AppDelegate)?.uploadCompleted(url: url)
    }

    func faild(errorMsg: String? = "") {
        (NSApplication.shared.delegate as? AppDelegate)?.uploadFaild(errorMsg: errorMsg)
    }
    
    /*********************************************************** static *******************************************************************/
    
    static func cancelUpload() {
        Session.default.session.getTasksWithCompletionHandler({ dataTasks, uploadTasks, downloadTasks in
            uploadTasks.forEach { $0.cancel() }
        })
    }
    
    ///
    /// 作为上传的统一入口
    /// As a unified entry point for uploads
    ///
    static func upload(url: URL, _ defaultHost: Host? = nil) {
        guard let host = defaultHost ?? ConfigManager.shared.getDefaultHost() else {
            return
        }
        
        let fileExtensions = BaseUploader.getFileExtensions()
        if (!BaseUploader.checkFileExtensions(fileExtensions: fileExtensions, fileExtension: url.pathExtension)) {
            (NSApplication.shared.delegate as? AppDelegate)?.uploadFaild(errorMsg: "File format not supported!".localized)
            return
        }
        
        if let attr = try? FileManager.default.attributesOfItem(atPath: url.path), let fileSize = attr[FileAttributeKey.size] as? UInt64 {
            let limitSize = BaseUploader.getFileSizeLimit()
            if (!BaseUploader.checkFileSize(fileSize: fileSize, limitSize: limitSize)) {
                
                let errorMsg = "\("File is over the size limit! Limit:".localized)\(ByteCountFormatter.string(fromByteCount: Int64(limitSize), countStyle: .binary))"
                (NSApplication.shared.delegate as? AppDelegate)?.uploadFaild(errorMsg: errorMsg)
                return
            }
        }
        
        /* 有新的图床在这里进行判断调用 */
        switch host.type {
        case .smms:
            SmmsUploader.shared.upload(url, host: host)
            break
        case .custom:
            CustomUploader.shared.upload(url, host: host)
            break
        case .upyun_USS:
            UpYunUploader.shared.upload(url, host: host)
            break
        case .qiniu_KODO:
            QiniuUploader.shared.upload(url, host: host)
            break
        case .aliyun_OSS:
            AliyunUploader.shared.upload(url, host: host)
            break
        case .tencent_COS:
            TencentUploader.shared.upload(url, host: host)
            break
        case .github:
            GithubUploader.shared.upload(url, host: host)
            break
        case .gitee:
            GiteeUploader.shared.upload(url, host: host)
            break
        case .weibo:
            WeiboUploader.shared.upload(url, host: host)
            break
        case .amazon_S3:
            AmazonS3Uploader.shared.upload(url, host: host)
            break
        case .imgur:
            ImgurUploader.shared.upload(url, host: host)
            break
        case .baidu_BOS:
            BaiduUploader.shared.upload(url, host: host)
            break
        }
    }
    
    ///
    /// 作为上传的统一入口
    /// As a unified entry point for uploads
    ///
    static func upload(data: Data, _ defaultHost: Host? = nil) {
        guard let host = defaultHost ?? ConfigManager.shared.getDefaultHost() else {
            return
        }
        
        let limitSize = BaseUploader.getFileSizeLimit()
        if (!BaseUploader.checkFileSize(fileSize: UInt64(data.count), limitSize: limitSize)) {
            
            let errorMsg = "\("File is over the size limit! Limit:".localized)\(ByteCountFormatter.string(fromByteCount: Int64(limitSize), countStyle: .binary))"
            (NSApplication.shared.delegate as? AppDelegate)?.uploadFaild(errorMsg: errorMsg)
            return
        }
        
        /* 有新的图床在这里进行判断调用 */
        switch host.type {
        case .smms:
            SmmsUploader.shared.upload(data, host: host)
            break
        case .custom:
            CustomUploader.shared.upload(data, host: host)
            break
        case .upyun_USS:
            UpYunUploader.shared.upload(data, host: host)
            break
        case .qiniu_KODO:
            QiniuUploader.shared.upload(data, host: host)
            break
        case .aliyun_OSS:
            AliyunUploader.shared.upload(data, host: host)
            break
        case .tencent_COS:
            TencentUploader.shared.upload(data, host: host)
            break
        case .github:
            GithubUploader.shared.upload(data, host: host)
            break
        case .gitee:
            GiteeUploader.shared.upload(data, host: host)
            break
        case .weibo:
            WeiboUploader.shared.upload(data, host: host)
            break
        case .amazon_S3:
            AmazonS3Uploader.shared.upload(data, host: host)
            break
        case .imgur:
            ImgurUploader.shared.upload(data, host: host)
            break
        case .baidu_BOS:
            BaiduUploader.shared.upload(data, host: host)
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
        case .baidu_BOS:
            return BaiduUploader.fileExtensions
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
}
