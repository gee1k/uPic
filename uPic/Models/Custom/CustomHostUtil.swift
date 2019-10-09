//
//  CustomHostUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/7/17.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

class CustomHostUtil {

    /**
     解析请求头或者body字符串
     */
    public static func parseHeadersOrBodys(_ str: String) -> [Dictionary<String, String>] {
        var arr: [Dictionary<String, String>] = []
        if let json = try? JSON(data: str.data(using: String.Encoding.utf8)!) {
            if let jsonArr = json.array {
                for jsonItem in jsonArr {
                    arr.append(jsonItem.dictionaryObject as! [String: String])
                }
            }
        }
        return arr
    }

    /**
     格式化请求头或者body为字符串
     */
    public static func formatHeadersOrBodys(_ arr: [Dictionary<String, String>]) -> String {
        return JSON(arr).rawString() ?? ""
    }

    /**
     获取json结果中的url
     */
    public static func parseResultUrl(_ json: JSON, _ resultPath: String) -> String {
        var retUrl = ""
        let retJson = json

        if !resultPath.isEmpty {
            if let pathJSON = try? JSON(data: resultPath.data(using: String.Encoding.utf8)!) {
                if let pathArr = pathJSON.arrayObject {
                    var path: [JSONSubscriptType] = []
                    for p in pathArr {
                        if (p is Int) {
                            path.append(p as! Int)
                        } else if (p is String) {
                            path.append(p as! String)
                        }
                    }
                    retUrl = retJson[path].rawString() ?? ""
                }
            }
        }

        return retUrl
    }
}
