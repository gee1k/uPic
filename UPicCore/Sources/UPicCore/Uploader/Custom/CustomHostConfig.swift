//
//  CustomHostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class CustomHostConfig: HostConfig {
    dynamic public var url: String?
    dynamic public var method: CustomRequestMethod = .POST
    dynamic public var field: String?
    dynamic public var bodys: [HeaderOrBodyModel] = []
    dynamic public var headers: [HeaderOrBodyModel] = []
    dynamic public var resultPath: String?
    dynamic public var domain: String = ""
    dynamic public var saveKeyPath: String?
    dynamic public var suffix: String = ""
    dynamic public var useBase64: Bool = false
    
    public override func isValid() -> Bool {
        guard let url = self.url, !url.isEmpty,
            let field = self.field, !field.isEmpty else {
            return false
        }
        return true
    }
}
