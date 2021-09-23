//
//  S3Uploader.swift
//  uPic
//
//  Created by Svend Jin on 2020/8/12.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation
import SotoS3


class S3Uploader: BaseUploader {

    static let shared = S3Uploader()
    static let fileExtensions: [String] = []
    
    
    func _upload(_ fileUrl: URL?, fileData: Data?, host: Host) {
        guard let data = host.data else {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        super.start()

        let config = data as! S3HostConfig

        let customize = config.customize
        let bucket = config.bucket
        let accessKey = config.accessKey
        let secretKey = config.secretKey
        let domain = config.domain
        
        var region = config.region == nil ? .useast1 : SotoS3.Region(rawValue: config.region!)
        
        var endpoint = config.endpoint
        
        if customize {
            region = .useast1
        } else {
            endpoint = S3Region.endPoint(config.region)
        }
        
        let saveKeyPath = config.saveKeyPath
        
        let url = S3Util.computeUrl(bucket: bucket, region: config.region, customize: customize, endpoint: endpoint)

        if url.isEmpty {
            super.faild(errorMsg: "There is a problem with the map bed configuration, please check!".localized)
            return
        }

        guard let configuration = BaseUploaderUtil.getSaveConfiguration(fileUrl, fileData, saveKeyPath) else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        let retData = configuration["retData"] as? Data
        let fileName = configuration["fileName"] as! String
        let mimeType = configuration["mimeType"] as! String
        let saveKey = configuration["saveKey"] as! String
        
        guard let bodyData = retData else {
            super.faild(errorMsg: "Invalid file")
            return
        }
        
        let suffix = BaseUploaderUtil._parseVariables(config.suffix, fileName, otherVariables: nil)
        
        let s3Endpoint = S3Util.computedS3Endpoint(endpoint)
        
        let client = AWSClient(
            credentialProvider: .static(accessKeyId: accessKey, secretAccessKey: secretKey),
            httpClientProvider: .createNew
        )
        let s3 = S3(client: client, region: region, endpoint: s3Endpoint, timeout: .minutes(1))
            
        var bb = ByteBuffer(data: bodyData)
        let bufferSize = bb.readableBytes
        let blockSize = 32*1024
        var sendedSize = 0
        let payload = AWSPayload.stream(size: bufferSize) { eventLoop in
            let size = min(blockSize, bb.readableBytes)
            // don't ask for 0 bytes
            if size == 0 {
                return eventLoop.makeSucceededFuture(.end)
            }
            let slice = bb.readSlice(length: size)!
            // Update your UI here
            sendedSize += size
            let precent = Double(sendedSize) / Double(bufferSize)
            super.progress(percent: precent)
            return eventLoop.makeSucceededFuture(.byteBuffer(slice))
        }

        let putObjectRequest = S3.PutObjectRequest(
            acl: .publicRead,
            body: payload,
            bucket: bucket,
            contentType: mimeType,
            key: saveKey
        )
        let put = s3.putObject(putObjectRequest)
        
        put.whenComplete { (result: Result) in
            switch(result) {
            case .success(_):
                if domain.isEmpty {
                    super.completed(url: "\(url)/\(saveKey)\(suffix)", retData, fileUrl, fileName)
                } else {
                    super.completed(url: "\(domain)/\(saveKey)\(suffix)", retData, fileUrl, fileName)
                }
                break

            case .failure(let e):
                if let s3Error = e as? S3ErrorType {
                    super.faild(errorMsg: s3Error.description)
                } else if let s3Error = e as? AWSResponseError {
                    super.faild(errorMsg: s3Error.message)
                } else {
                    super.faild(errorMsg: e.localizedDescription)
                }
                break

            }
            try? client.syncShutdown()
        }
    }
    
    
    func upload(_ fileUrl: URL, host: Host) {
        self._upload(fileUrl, fileData: nil, host: host)
    }
    
    func upload(_ fileData: Data, host: Host) {
        self._upload(nil, fileData: fileData, host: host)
    }
}
