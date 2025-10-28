//
//  Imgur.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON

private struct ReseponseModel: HandyJSON {
    var data: ReseponseDataModel?
    var success: Bool!
    var status: Int!
}

private struct ReseponseDataModel: HandyJSON {
    var error: String?
    var link: String?
}

public class ImgurUploader {
    
    internal static let allowExtensions: [String] = ["jpg", "jpeg", "png", "gif", "apng", "tiff", "tif", "bmp", "xcf", "webp", "mp4", "mov", "avi", "webm"]
    
    internal static let limitSize: UInt64 = 10 * 1024 * 1024
   
    private static func getRequestConfig(_ config: ImgurHostConfig, filename: String, data: Data) -> RequestConfig {
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader.authorization("Client-ID \(config.clientId!)"))
        headers.add(HTTPHeader.contentType("multipart/form-data"))
        headers.add(HTTPHeader.defaultUserAgent)
        
       
        let multipartFormData = MultipartFormData()
        multipartFormData.append("base64".data(using: .utf8)!, withName: "type")
        multipartFormData.append(filename.data(using: .utf8)!, withName: "name")
        multipartFormData.append(data.base64EncodedData(), withName: "image")
        
        var requestConfig = RequestConfig()
        requestConfig.url = "https://api.imgur.com/3/image"
        requestConfig.method = .post
        requestConfig.headers = headers
        requestConfig.multipartFormData = multipartFormData
        
        return requestConfig
    }
    
    internal static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.getConfig(ImgurHostConfig.self), config.isValid() else {
            ctx._uploadFail(.invalidConfig)
            return
        }
        
        let requestConfig = self.getRequestConfig(config, filename: filename, data: data)
        
        ctx.requester.upload(requestConfig).validate().uploadProgress{ progress in
            ctx._uploadProgress(progress.fractionCompleted)
        }.responseString{ response in
            switch response.result {
            case .success(let value):
                guard let model = ReseponseModel.deserialize(from: value) else {
                    ctx._uploadFail(.invalidResponse, detailError: response.data?.toString())
                    return
                }
                
                if  model.success, let link = model.data?.link?.urlDecoded() {
                    ctx._uploadComplete(link)
                } else {
                    ctx._uploadFail(model.data?.error, detailError: response.data?.toString())
                }
                
            case .failure(let error):
                ctx._uploadFail(error.localizedDescription, detailError: response.data?.toString())
            }
        }
    }
}
