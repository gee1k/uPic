//
//  UPicUploader.swift
//  uPic
//
//  Created by Svend Jin on 2020/1/10.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation
import UIKit
import UPicCore
import Photos
import Defaults

struct UploadItem {
    var asset: PHAsset?
    var data: Data?
    var thumbnailData: Data?
    var pixelWidth: Int = 0
    var pixelHeight: Int = 0
    var originalFilename: String?
}

class UPicUploader {
    
    static var finishHandler: (() -> Void)?

    static var returnItems: (([UploadItem]) -> Void)?
    
    static func upload(hostModel: HostModel, fileURLs: [URL]){
        Logger.shared.verbose("[UPLOAD] 通过 URL 上传 -> \(fileURLs.count) 个")
        
        var items: [UploadItem] = []
        let group = DispatchGroup()
        for url in fileURLs {
            Logger.shared.verbose("[UPLOAD] 通过 URL 获取 Data -> \(url.path)")
            guard var data = try? Data(contentsOf: url) else {
                Logger.shared.warn("[UPLOAD] 通过 URL 获取 Data 失败")
                continue
            }
            group.enter()
            
            var originalFilename = url.lastPathComponent
            
            if url.lastPathComponent.isHEICWithPath {
                if let uiImage = UIImage(data: data) {
                    data = uiImage.jpegData(compressionQuality: 1.0) ?? data
                    originalFilename = "\(url.lastPathComponent.deletingPathExtension).jpg"
                }
            }
            
            let image = UIImage(data: data)
            var uploadItem = UploadItem()
            uploadItem.originalFilename = originalFilename
            uploadItem.pixelWidth = Int(image?.size.width ?? 0)
            uploadItem.pixelHeight = Int(image?.size.height ?? 0)
            uploadItem.data = data
            
            var thumbnailData = image?.jpegData(compressionQuality: 0.3)
            if thumbnailData == nil && url.lastPathComponent.fileType == "video" {
                getVideoPreViewImage(url) { thumbnailImage in
                    thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
                    uploadItem.thumbnailData = thumbnailData
                    items.append(uploadItem)
                    group.leave()
                }
            } else {
                uploadItem.thumbnailData = thumbnailData
                items.append(uploadItem)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            upload(hostModel: hostModel, items: items)
        }
    }
    
    static func upload(hostModel: HostModel, fileData: Data){
        Logger.shared.verbose("[UPLOAD] 通过 Data 上传")
        
        var uploadItem = UploadItem()
        let image = UIImage(data: fileData)
        uploadItem.pixelWidth = Int(image?.size.width ?? 0)
        uploadItem.pixelHeight = Int(image?.size.height ?? 0)
        uploadItem.data = fileData
        
        var thumbnailData = image?.jpegData(compressionQuality: 0.3)
        if thumbnailData == nil && fileData.isVideo, let videoURL = URL(dataRepresentation: fileData, relativeTo: nil) {
            getVideoPreViewImage(videoURL) { thumbnailImage in
                thumbnailData = thumbnailImage?.jpegData(compressionQuality: 0.8)
                uploadItem.thumbnailData = thumbnailData
                upload(hostModel: hostModel, items: [uploadItem])
            }
        } else {
            uploadItem.thumbnailData = thumbnailData
            upload(hostModel: hostModel, items: [uploadItem])
        }
        
    }
    
    static func upload(hostModel: HostModel, images: [UIImage]) {
        Logger.shared.verbose("[UPLOAD] 通过 UIImage 上传 -> \(images.count) 个")
        
        var items: [UploadItem] = []
        
        for image in images {
            var uploadItem = UploadItem()
            uploadItem.pixelWidth = Int(image.size.width)
            uploadItem.pixelHeight = Int(image.size.height)
            uploadItem.data = image.pngData()
            uploadItem.thumbnailData = image.jpegData(compressionQuality: 0.3)
            items.append(uploadItem)
        }
        
        upload(hostModel: hostModel, items: items)
    }
    
    static func upload(hostModel: HostModel, assets: [PHAsset]){
        
        Logger.shared.verbose("[UPLOAD] 通过相册上传 -> \(assets.count) 个")
        
        var items: [UploadItem] = []
        assets.forEach { (asset, _ ) in
            asset.getData { data, originalFilename  in
                var uploadItem = UploadItem()
                uploadItem.asset = asset
                uploadItem.pixelWidth = asset.pixelWidth
                uploadItem.pixelHeight = asset.pixelHeight
                uploadItem.data = data
                uploadItem.originalFilename = originalFilename
                
                // 获取预览图
                asset.getThumbnailData { thumbnailData in
                    uploadItem.thumbnailData = thumbnailData ?? data
                    
                    items.append(uploadItem)
                    
                    if items.count == assets.count {
                        // completed
                        upload(hostModel: hostModel, items: items)
                    }
                }
            }
        }
    }

    static func upload(hostModel: HostModel, items: [UploadItem]) {
        Logger.shared.verbose("[UPLOAD] 执行上传 -> \(items.count)个， 图床信息 -> \(hostModel.serialize() ?? "")")
        
        guard returnItems ==  nil else {
            Logger.shared.verbose("[UPLOAD] 执行上传前确认")
            returnItems?(items)
            return
        }
        
        Logger.shared.verbose("[UPLOAD] 过滤 data 为空的上传项")
        
        let items = items.filter { item in
            return item.data != nil
        }
        
        Logger.shared.verbose("[UPLOAD] 过滤后的上传项数量->\(items.count)")
        
        if items.count == 0 {
            UPicUploader.finishHandler?()
            return
        }
        
        Defaults[.isUploading] = true
        
        let banner = UploadNotificationBanner(total: items.count)
        banner.show()
        
        Logger.shared.verbose("[UPLOAD] 开始执行上传任务队列")
        let queue = TaskQueue()
        var _lastUploadStatus = false
        items.forEach{ (item, index) in
            guard let data = item.data else { return }
            queue.tasks += { result, next in
                
                let size = ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .decimal)
                Logger.shared.verbose("[UPLOAD] 开始执行上传任务 -> \(index + 1)/\(items.count) - 文件大小 -> \(size)")
                
                banner.next(item.thumbnailData ?? data)
                
                UPicCore.shared.progress{ progress in
                    debugPrint("上传进度 -> \(progress)")
                    
                    DispatchQueue.main.async {
                        banner.progress(progress)
                    }
                    
                }.complete{ url in
                    Logger.shared.verbose("[UPLOAD] 上传任务 \(index + 1) 成功 -> \(url)")
                    saveHistory(item: item, url: url)
                    
                    _lastUploadStatus = true
                    next(nil)
                }.fail{ errorMessage, detailError  in
                    Logger.shared.error("[UPLOAD] 上传任务 \(index + 1) 失败 -> \(errorMessage) - \(detailError ?? "")")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        Tool.shared.postNotification(title: "Upload Fail".localized, body: errorMessage, theme: .error, position: .top)
                        Tool.shared.tapticEngine(.error)
                    }
                    
                    _lastUploadStatus = false
                    next(nil)
                }.upload(hostModel: hostModel, fileData: data, filename: item.originalFilename)
            }
        }
        
        queue.run {
            Logger.shared.verbose("[UPLOAD] 上传任务队列结束")
            
            Defaults[.isUploading] = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if _lastUploadStatus {
                    banner.finish()
                } else {
                    banner.dismiss()
                }
                UPicUploader.finishHandler?()
            }
        }
        
        banner.cancelAction = {
            Logger.shared.verbose("[UPLOAD] 取消上传")
            
            Defaults[.isUploading] = false
            UPicCore.shared.cancel()
            queue.cancel()
            banner.dismiss()
        }
    }
    
    private static func saveHistory(item: UploadItem, url: String) {
        DispatchQueue.main.async {
            Logger.shared.verbose("[UPLOAD] 储存上传历史 -> \(url)")
            let historyModel = HistoryModel()
            historyModel.url = url
            historyModel.thumbnailData = item.thumbnailData
            historyModel.size = item.data?.count ?? 0
            historyModel.pixelWidth = item.pixelWidth
            historyModel.pixelHeight = item.pixelHeight
            historyModel.originalFilename = item.originalFilename
            DBManager.shared.insertHistory(historyModel)
            HostNotifier.postNotification(.addHistory)
        }
    }
}
