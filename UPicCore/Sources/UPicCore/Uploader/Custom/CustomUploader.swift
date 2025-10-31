//
//  Custom.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Alamofire
import Foundation

public class CustomUploader {
    static let allowExtensions: [String] = []
    
    private static func getRequestConfig(_ config: CustomHostConfig, filename: String, saveKey: String, data: Data) -> RequestConfig {
        let otherVariables = ["saveKey": saveKey]
        
        let url = FormatUtil._parseVariables(config.url!, filename, otherVariables: otherVariables)
        
        var headers = HTTPHeaders()
        let headerArrs = config.headers
        for header in headerArrs {
            let value = FormatUtil._parseVariables(header.value, filename, otherVariables: otherVariables)
            headers.add(name: header.key, value: value)
        }
        
        var isApplicationJson = false
        for (_, header) in headers.enumerated() {
            if header.name.lowercased() != "content-type" {
                continue
            }
            if header.value.lowercased().contains("application/json") {
                isApplicationJson = true
                break
            }
        }
        
        var hasContentType = false
        hasContentType = headerArrs.contains { $0.key.lowercased() == "content-type" }
        if !hasContentType {
            headers.add(HTTPHeader.contentType("multipart/form-data"))
        }
        
        let httpMethod = HTTPMethod(rawValue: config.method.rawValue)
        
        var requestConfig = RequestConfig()
        requestConfig.url = url
        requestConfig.method = httpMethod
        requestConfig.headers = headers
       
        if isApplicationJson {
            var parameters = Parameters()
            let bodyArrs = config.bodys
            for body in bodyArrs {
                let value = FormatUtil._parseVariables(body.value, filename, otherVariables: otherVariables)
                parameters[body.key] = value
            }
            parameters[config.field!] = data.base64EncodedString()
            requestConfig.parameters = parameters
            requestConfig.encoding = JSONEncoding.default
        } else {
            let multipartFormData = MultipartFormData()
            multipartFormData.append(data, withName: config.field!, fileName: saveKey.lastPathComponent, mimeType: saveKey.mimeType)
            let bodyArrs = config.bodys
            for body in bodyArrs {
                let value = FormatUtil._parseVariables(body.value, filename, otherVariables: otherVariables)
                multipartFormData.append(value.data(using: .utf8)!, withName: body.key)
            }
            requestConfig.multipartFormData = multipartFormData
        }
        
        return requestConfig
    }
    
    static func handle(_ ctx: UPicCore, model: HostModel, data: Data, filename: String) {
        guard let config = model.getConfig(CustomHostConfig.self), config.isValid() else {
            ctx._uploadFail(.invalidConfig)
            return
        }
        
        let saveKey = FormatUtil.parseSaveKeyPath(config.saveKeyPath, filename)
        
        let requestConfig = getRequestConfig(config, filename: filename, saveKey: saveKey, data: data)
        
        var isApplicationJson = false
        for (_, header) in requestConfig.headers!.enumerated() {
            if header.name.lowercased() != "content-type" {
                continue
            }
            if header.value.lowercased().contains("application/json") {
                isApplicationJson = true
                break
            }
        }
        
        if isApplicationJson {
            ctx.requester.request(requestConfig).validate().uploadProgress { progress in
                ctx._uploadProgress(progress.fractionCompleted)
            }.responseString { response in
                switch response.result {
                case .success(let value):
                    guard let stringData = value.data(using: .utf8),
                          let jsonValue = try? JSONSerialization.jsonObject(with: stringData, options: [])
                    else {
                        ctx._uploadComplete(value)
                        return
                    }
                    
                    guard let resultPath = formatResultPath(config.resultPath), let data = resultPath.data(using: .utf8) else {
                        ctx._uploadComplete(value)
                        return
                    }
                    
                    guard let pathArr = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
                        ctx._uploadComplete(value)
                        return
                    }
                    
                    let resultUrl = getValueFromPath(object: jsonValue, path: pathArr)
                    var retUrl = resultUrl == nil ? value : "\(resultUrl!)\(config.suffix)"
                    if !config.domain.isEmpty {
                        if retUrl.starts(with: "/") {
                            retUrl = "\(config.domain)\(retUrl)"
                        } else {
                            retUrl = "\(config.domain)/\(retUrl)"
                        }
                    }
                    ctx._uploadComplete(retUrl)
                    
                case .failure(let error):
                    ctx._uploadFail(error.localizedDescription)
                }
            }
        } else {
            ctx.requester.upload(requestConfig).validate().uploadProgress { progress in
                ctx._uploadProgress(progress.fractionCompleted)
            }.responseString { response in
                switch response.result {
                case .success(let value):
                    guard let stringData = value.data(using: .utf8),
                          let jsonValue = try? JSONSerialization.jsonObject(with: stringData, options: [])
                    else {
                        ctx._uploadComplete(value)
                        return
                    }
                    
                    guard let resultPath = formatResultPath(config.resultPath), let data = resultPath.data(using: .utf8) else {
                        ctx._uploadComplete(value)
                        return
                    }
                    
                    guard let pathArr = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
                        ctx._uploadComplete(value)
                        return
                    }
                    
                    let resultUrl = getValueFromPath(object: jsonValue, path: pathArr)
                    var retUrl = resultUrl == nil ? value : "\(resultUrl!)\(config.suffix)"
                    if !config.domain.isEmpty {
                        if retUrl.starts(with: "/") {
                            retUrl = "\(config.domain)\(retUrl)"
                        } else {
                            retUrl = "\(config.domain)/\(retUrl)"
                        }
                    }
                    
                    ctx._uploadComplete(retUrl)
                    
                case .failure(let error):
                    ctx._uploadFail(error.localizedDescription, detailError: response.data?.toString())
                }
            }
        }
     }
    
    // MARK: - Format resultPath to avoid problems with single quotes and other symbols

    private static func formatResultPath(_ resultPath: String?) -> String? {
        guard var path = resultPath else {
            return nil
        }
        path = path.replacingOccurrences(of: "'", with: "\"").replacingOccurrences(of: "，", with: ",")
        return path
    }
    
    // MARK: - Get value from JSON object according to specified path

    private static func getValueFromPath(object: Any?, path: [Any]) -> String? {
        guard let object = object else { return nil }
        if let keyValue = object as? [String: Any] {
            guard let first = path.first as? String else { return nil }
            var value: Any? = keyValue[first]
            var newPath = path
            newPath.remove(at: 0)
            if newPath.count > 0 {
                value = getValueFromPath(object: value, path: newPath)
            }
            return value as? String
        } else if let group = object as? [Any] {
            guard let first = path.first as? Int else { return nil }
            var value: Any? = group.elementForIndex(idx: first)
            var newPath = path
            newPath.remove(at: 0)
            if newPath.count > 0 {
                value = getValueFromPath(object: value, path: newPath)
            }
            return value as? String
        } else {
            return nil
        }
    }
}
