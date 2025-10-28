//
//  UPicCore.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public enum UploadError: String {
    case invalidSignature
    case invalidConfig
    case invalidResponse
    case unknownHostType
    case notSupportedFile
    case sizeLimit
    case unknownError
    
    var displayMessage: String {
        switch self {
        case .invalidSignature: return String(localized: "Invalid signature")
        case .invalidConfig: return String(localized: "Invalid config")
        case .invalidResponse: return String(localized: "Invalid response")
        case .unknownHostType: return String(localized: "Unknown host type")
        case .notSupportedFile: return String(localized: "File format not supported")
        case .sizeLimit: return String(localized: "File is over the size limit! Limit:")
        case .unknownError: return String(localized: "Unknown Error")
        }
    }
}

public class UPicCore {
    public static var shared = UPicCore()
    
    let requester = Requester.shared
    
    public typealias ProgressHandler = (Double) -> Void
    public typealias CompletionHandler = (String) -> Void
    public typealias FailHandler = (String, String?) -> Void
    
    private var uploadCompletionHandler: ((String) -> Void)?
    
    private var uploadFailHandler: ((String, String?) -> Void)?
    
    private var uploadProgressHandler: ((Double) -> Void)?
    
    @discardableResult
    public func cancel() -> Self {
        requester.currentRequest?.cancel()
        return self
    }
    
    @discardableResult
    public func upload(hostModel: HostModel, fileData: Data, filename: String?) -> Self {
        let filename = filename ?? FormatUtil._getRandomFileName(Swime.mimeType(data: fileData)?.ext)
        
        guard let data = beforeUpload(hostModel: hostModel, fileData: fileData) else {
            return self
        }
        
        DispatchQueue.main.async {
            switch hostModel.type {
            case .aliyun_oss:
                AliyunUploader.handle(self, model: hostModel, data: data, filename: filename)
            case .s3:
                S3Uploader.handle(self, model: hostModel, data: data, filename: filename)
            case .tencent_cos:
                TencentUploader.handle(self, model: hostModel, data: data, filename: filename)
            case .baidu_bos:
                BaiduUploader.handle(self, model: hostModel, data: data, filename: filename)
            case .upyun_uss:
                UpyunUploader.handle(self, model: hostModel, data: data, filename: filename)
            case .qiniu_kodo:
                QiniuUploader.handle(self, model: hostModel, data: data, filename: filename)
            case .github:
                GithubUploader.handle(self, model: hostModel, data: data, filename: filename)
            case .gitee:
                GiteeUploader.handle(self, model: hostModel, data: data, filename: filename)
            case .imgur:
                ImgurUploader.handle(self, model: hostModel, data: data, filename: filename)
            case .weibo:
                WeiboUploader.handle(self, model: hostModel, data: data, filename: filename)
            case .smms:
                SmmsUploader.handle(self, model: hostModel, data: data, filename: filename)
            case .custom:
                CustomUploader.handle(self, model: hostModel, data: data, filename: filename)
            default:
                self._uploadFail(.unknownHostType)
            }
        }
        
        return self
    }
    
    @discardableResult
    public func upload(hostModel: HostModel, fileUrl: URL) -> Self {
        guard let data = try? Data(contentsOf: fileUrl, options: []) else {
            return self
        }
        
        return upload(hostModel: hostModel, fileData: data, filename: fileUrl.lastPathComponent)
    }
    
    private func beforeUpload(hostModel: HostModel, fileData: Data) -> Data? {
        if !checkFileExtensionIsAllow(hostType: hostModel.type, data: fileData) {
            _uploadFail(.notSupportedFile)
            return nil
        }
        
        if !checkFileSize(hostType: hostModel.type, fileData: fileData) {
            _uploadFail(.sizeLimit)
            return nil
        }
        
        return fileData
    }
    
    @discardableResult
    public func progress(closure: @escaping ProgressHandler) -> Self {
        uploadProgressHandler = closure
        return self
    }
    
    @discardableResult
    public func complete(closure: @escaping CompletionHandler) -> Self {
        uploadCompletionHandler = closure
        return self
    }
    
    @discardableResult
    public func fail(closure: @escaping FailHandler) -> Self {
        uploadFailHandler = closure
        return self
    }
    
    func _uploadProgress(_ progress: Double) {
        uploadProgressHandler?(progress)
    }
    
    func _uploadComplete(_ url: String) {
        uploadCompletionHandler?(url)
    }
    
    func _uploadFail(_ error: UploadError, append: String? = "", detailError: String? = nil) {
        var errorMessage = error.displayMessage
        if let append = append {
            errorMessage = "\(errorMessage) \(append)"
        }
        _uploadFail(errorMessage, detailError: detailError)
    }
    
    func _uploadFail(_ errorMessage: String?, detailError: String? = nil) {
        uploadFailHandler?(errorMessage ?? UploadError.unknownError.rawValue, detailError)
    }
    
    // MARK: - Check if the file type is allowed

    private func checkFileExtensionIsAllow(hostType: HostType, data: Data) -> Bool {
        let ext = Swime.mimeType(data: data)?.ext ?? "jpg"
        
        var allowExtensions: [String] = []
        
        switch hostType {
        case .aliyun_oss:
            allowExtensions = AliyunUploader.allowExtensions
        case .s3:
            allowExtensions = S3Uploader.allowExtensions
        case .tencent_cos:
            allowExtensions = TencentUploader.allowExtensions
        case .baidu_bos:
            allowExtensions = BaiduUploader.allowExtensions
        case .upyun_uss:
            allowExtensions = UpyunUploader.allowExtensions
        case .qiniu_kodo:
            allowExtensions = QiniuUploader.allowExtensions
        case .github:
            allowExtensions = GithubUploader.allowExtensions
        case .gitee:
            allowExtensions = GiteeUploader.allowExtensions
        case .imgur:
            allowExtensions = ImgurUploader.allowExtensions
        case .weibo:
            allowExtensions = WeiboUploader.allowExtensions
        case .smms:
            allowExtensions = SmmsUploader.allowExtensions
        case .custom:
            allowExtensions = CustomUploader.allowExtensions
        }
        
        return allowExtensions.count == 0 || allowExtensions.contains(ext)
    }
    
    private func checkFileSize(hostType: HostType, fileData: Data) -> Bool {
        let size = UInt64(fileData.count)
        
        var limitSize: UInt64 = 0
        
        switch hostType {
        case .imgur:
            limitSize = ImgurUploader.limitSize
        default: break
        }
        
        if limitSize <= 0 {
            return true
        }
        
        if size > limitSize {
            _uploadFail(.sizeLimit, append: "\(ByteCountFormatter.string(fromByteCount: Int64(limitSize), countStyle: .binary))")
            return false
        }

        return true
    }
}
