//
//  HeaderOrBodyModel.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import HandyJSON

public class HeaderOrBodyModel: Identifiable, HandyJSON {
    public var id = UUID().uuidString
    public var key: String = ""
    public var value: String = ""

    public required init() {}

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    public func isValid() -> Bool {
        return !self.key.isEmpty && !self.value.isEmpty
    }
}
