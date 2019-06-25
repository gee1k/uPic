//
//  UpYunUtil.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/16.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import SwiftyJSON

public class UpYunUtil {
    private static let expiration = 1800

    static func getPolicy(policyDict: Dictionary<String, Any>) -> String {
        // MARK: 将 policy 字典转成 JSON 然后转成 Data 再转 Base64

        var policyDict = policyDict

        if policyDict["expiration"] == nil {
            policyDict["expiration"] = Date().timeStamp + expiration
        }
        let policyJSON = JSON(policyDict)
        let policyData = try! policyJSON.rawData()
        return policyData.toBase64()
    }
}
