//
//  QiniuUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/23.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class QiniuUtil {
    private static let expiration = 1800

    struct PutPolicy: Codable {
        let scope: String
        let deadline: Int
    }

    static func getToken(scope: String, accessKey: String, secretKey: String) -> String {

        let deadline = Date().timeStamp + expiration
        let putPolicy = PutPolicy.init(scope: scope, deadline: Int(deadline))

        let jsonData = try! JSONEncoder().encode(putPolicy)
        let base64String = jsonData.base64EncodedString().urlSafeBase64()

        let hmac = base64String.calculateHMACByKey(key: secretKey)
        let encodeString = hmac.toBase64()
        let encodedSignString = encodeString!.urlSafeBase64()
        return "\(accessKey):\(encodedSignString):\(base64String)"
    }
}
