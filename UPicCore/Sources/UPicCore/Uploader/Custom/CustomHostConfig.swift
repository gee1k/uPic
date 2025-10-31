//
//  CustomHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class CustomHostConfig: HostConfig {
    public dynamic var url: String?
    public dynamic var method: CustomRequestMethod = .POST
    public dynamic var field: String?
    public dynamic var bodys: [HeaderOrBodyModel] = []
    public dynamic var headers: [HeaderOrBodyModel] = []
    public dynamic var resultPath: String?
    public dynamic var domain: String = ""
    public dynamic var saveKeyPath: String?
    public dynamic var suffix: String = ""
    public dynamic var useBase64: Bool = false

    override public func isValid() -> Bool {
        guard let url = url, !url.isEmpty,
              let field = field, !field.isEmpty
        else {
            return false
        }
        return true
    }
}
