//
//  Host.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON

class Host: Equatable, CustomDebugStringConvertible, Codable {

    static func ==(lhs: Host, rhs: Host) -> Bool {
        return (lhs.id == rhs.id)
    }

    static func getDefaultHost() -> Host {
        return Host(HostType.smms, data: HostConfig.create(type: .smms))
    }

    static func getIconNameByType(type: HostType) -> String {
        return "host_icon_\(type.rawValue)"
    }

    static func getIconByType(type: HostType) -> NSImage {
        let iconName = Host.getIconNameByType(type: type)
        let image = NSImage(named: iconName)!
        let width = 20.0, height = Double(image.size.height) / (Double(image.size.width) / width)
        image.size = NSSize(width: width, height: height)
        return image
    }

    var id: Int
    var name: String
    var type: HostType
    var data: HostConfig?

    init(_ type: HostType, data: HostConfig?) {
        self.id = Date().timeStamp
        self.name = type.name
        self.type = type
        self.data = data
    }

    public var debugDescription: String {
        return name + " " + "Type: \(type)" + " Data: \(data.debugDescription)"
    }


    func serialize() -> String {
        var dict = Dictionary<String, Any>()
        dict["id"] = self.id
        dict["name"] = self.name
        dict["type"] = self.type.rawValue
        dict["data"] = self.data?.serialize()

        return JSON(dict).rawString()!
    }
    
    func copy() -> Host {
        let newHost = Host.deserialize(str: self.serialize())!
        newHost.id = Date().timeStamp
        return newHost
    }

    static func deserialize(str: String) -> Host? {
        guard let data = str.data(using: String.Encoding.utf8), let json = try? JSON(data: data),let type = HostType(rawValue: json["type"].intValue) else {
            return nil
        }
        let hostData = HostConfig.deserialize(type: type, str: json["data"].string)

        let host = Host(type, data: hostData)
        host.id = json["id"].intValue
        host.name = json["name"].stringValue
        host.type = type
        host.data = hostData

        return host
    }
}
