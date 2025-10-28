//
//  Requester.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Alamofire

internal struct RequestConfig {
    var url: String!
    var method: HTTPMethod! = .post
    var data: Data?
    var multipartFormData: MultipartFormData?
    var parameters: Parameters?
    var encoding: ParameterEncoding! = URLEncoding.default
    var headers: HTTPHeaders?
}

internal class Requester {
    public static var shared = Requester()
    
    public var currentRequest: DataRequest?
    
    func request(_ config: RequestConfig) -> DataRequest {
        currentRequest = AF.request(config.url, method: config.method,  parameters: config.parameters, encoding: config.encoding, headers: config.headers)
        return currentRequest!
    }
    
    func upload(_ config: RequestConfig) -> DataRequest {
        if let data = config.data {
            currentRequest = AF.upload(data, to: config.url, method: config.method, headers: config.headers)
        } else {
            currentRequest = AF.upload(multipartFormData: config.multipartFormData!, to: config.url, method: config.method, headers: config.headers)
        }
        return currentRequest!
    }
}
