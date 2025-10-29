//
//  HostModel.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import HandyJSON
import SwiftData

@Model
public class HostModel: HandyJSON {
    public var id: String!
    public var name: String!
    public var typeRaw: String?
    public var dataRaw: Data?

    required public init() {}
    
    public init(_ type: HostType, data: HostConfig?) {
        self.id = "\(Date().secondStamp)"
        self.name = type.displayNname
        self.typeRaw = type.rawValue
        if let data = data,
           let jsonString = data.toJSONString(),
           let jsonData = jsonString.data(using: .utf8) {
            self.dataRaw = jsonData
        }
    }
    
    public func isValid() -> Bool {
        guard let _ = self.id, let _ = self.name, let typeRaw = self.typeRaw else {
            return false
        }

        // Check if dataRaw can be decoded to valid HostConfig
        if let dataRaw = self.dataRaw,
           let jsonString = String(data: dataRaw, encoding: .utf8),
           let hostConfig = HostConfig.deserialize(from: jsonString) {
            return hostConfig.isValid()
        }
        
        return true
    }
    
    public func copy() -> HostModel? {
        guard let str = self.serialize() else {
            return nil
        }
        let hostModel = HostModel.deserialize(serializeString: str)
        return hostModel
    }
    
    public func serialize() -> String? {
        return self.toJSONString()
    }
    
    public func getConfig<T: HostConfig>(_ type: T.Type) -> T? {
        guard let dataRaw = dataRaw,
              let jsonString = String(data: dataRaw, encoding: .utf8) else {
            return nil
        }
        return T.deserialize(from: jsonString)
    }

    public static func deserialize(serializeString: String, designatedPath: String? = nil) -> HostModel? {
        guard let model = HostModel.deserialize(from: serializeString, designatedPath: designatedPath) else {
            return nil
        }
        return model
    }
}
