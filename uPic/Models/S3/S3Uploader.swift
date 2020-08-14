//
//  S3Uploader.swift
//  uPic
//
//  Created by Svend Jin on 2020/8/12.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation
import AWSSDKSwiftCore
import S3
import NIO
import NIOHTTP1


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
        let region = AWSSDKSwiftCore.Region(rawValue: config.region)
        
        var endpoint = config.endpoint
        
        if !customize {
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
        
        let s3 = S3(accessKeyId: accessKey, secretAccessKey: secretKey, region: region, endpoint: S3Util.computedS3Endpoint(endpoint))
        
        let putObjectRequest = S3.PutObjectRequest(acl: .publicRead, body: bodyData, bucket: bucket, contentLength: Int64(bodyData.count), contentType: mimeType, key: saveKey)
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
                } else {
                    super.faild(errorMsg: e.localizedDescription)
                }
                break
                
            }
        }

    }
    
    func upload(_ fileUrl: URL, host: Host) {
        self._upload(fileUrl, fileData: nil, host: host)
    }
    
    func upload(_ fileData: Data, host: Host) {
        self._upload(nil, fileData: fileData, host: host)
    }
}
