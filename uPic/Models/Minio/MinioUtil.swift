//
//  MinioUtil.swift
//  uPic
//
//  Created by Svend Jin on 2020/4/12.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Foundation

class MinioUtil {
    static func computeUrl(endPoint: String, bucket: String, saveKey: String) -> String {
        if (endPoint.isEmpty) {
            return ""
        }
        var url = endPoint
        if url.hasSuffix("/") {
            url.removeLast()
        }
        return "\(url)/\(bucket)/\(saveKey)"
    }
}
