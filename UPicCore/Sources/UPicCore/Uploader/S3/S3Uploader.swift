//
//  S3Uploader.swift
//  uPic
//
//  Created by Svend Jin on 2020/08/16.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation
import SotoS3

public class S3Uploader {
    static let allowExtensions: [String] = []
    private static let schema = "https://"
    
    private static func computeUrl(bucket: String, customize: Bool, region: String?, endpoint: String?) -> String {
        if customize, let endpoint = endpoint {
            if endpoint.last == "/" {
                return "\(endpoint)\(bucket)"
            }
            return "\(endpoint)/\(bucket)"
        } else {
            let cEndpoint = S3Region.endPoint(region!)
            return "\(schema)\(bucket).\(cEndpoint)"
        }
    }
    
    private static func computedS3Endpoint(_ endpoint: String?) -> String? {
        if var point = endpoint, URL(string: point)?.scheme == nil {
            point = schema + point
            return point
        }
        return endpoint
    }
    
    static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.getConfig(S3HostConfig.self), config.isValid() else {
            ctx._uploadFail(.invalidConfig)
            return
        }
        
        let domain = config.domain
        let saveKey = FormatUtil.parseSaveKeyPath(config.saveKeyPath, filename)
        let suffix = FormatUtil._parseVariables(config.suffix, filename, otherVariables: nil)
        
        let s3Region = (config.region == nil || config.customize) ? SotoS3.Region.useast1 : SotoS3.Region(rawValue: config.region!)
        
        let url = computeUrl(bucket: config.bucket!, customize: config.customize, region: config.region, endpoint: config.endpoint)

        if url.isEmpty {
            ctx._uploadFail(.invalidConfig)
            return
        }
        
        let s3Endpoint = computedS3Endpoint(config.endpoint)
        
        let client = AWSClient(
            credentialProvider: .static(accessKeyId: config.accessKey!, secretAccessKey: config.secretKey!),
            httpClientProvider: .createNew
        )
        let s3 = S3(client: client, region: s3Region, endpoint: s3Endpoint)
            
        var payload: AWSPayload!
        // 如果是 AWS S3，采用流式上传，以获得最佳性能
        // 如果是其他自定义 S3 协议服务，则使用完整字节方式上传，以获得最佳兼容性
        if config.customize {
            payload = AWSPayload.data(data)
        } else {
            var bb = ByteBuffer(data: data)
            let bufferSize = bb.readableBytes
            let blockSize = 32 * 1024
            var sendedSize = 0
            payload = AWSPayload.stream(size: bufferSize) { eventLoop in
                let size = min(blockSize, bb.readableBytes)
                // don't ask for 0 bytes
                if size == 0 {
                    return eventLoop.makeSucceededFuture(.end)
                }
                let slice = bb.readSlice(length: size)!
                // Update your UI here
                sendedSize += size
                let precent = Double(sendedSize) / Double(bufferSize)
                ctx._uploadProgress(precent)
                return eventLoop.makeSucceededFuture(.byteBuffer(slice))
            }
        }
        
        var s3Acl = S3.ObjectCannedACL.publicRead
        if let acl = config.acl, let oAcl = S3.ObjectCannedACL(rawValue: acl) {
            s3Acl = oAcl
        }

        let putObjectRequest = S3.PutObjectRequest(
            acl: s3Acl,
            body: payload,
            bucket: config.bucket!,
            contentType: saveKey.mimeType,
            key: saveKey
        )
        let put = s3.putObject(putObjectRequest)
        
        put.whenComplete { (result: Result) in
            switch result {
            case .success:
                let url = domain.isEmpty ? url : domain
                let retUrl = "\(url)/\(saveKey)\(suffix)"
                ctx._uploadComplete(retUrl)
                
            case .failure(let e):
                if let s3Error = e as? S3ErrorType {
                    ctx._uploadFail(s3Error.description)
                } else {
                    ctx._uploadFail(e.localizedDescription)
                }
             }
            try? client.syncShutdown()
        }
    }
}
