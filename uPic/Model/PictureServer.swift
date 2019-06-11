//
//  PictureServer.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa

class PictureServer: Equatable, CustomDebugStringConvertible {
    
    static func == (lhs: PictureServer, rhs: PictureServer) -> Bool {
        return (lhs.id == rhs.id)
    }
    
    static func getIconNameByType(type: PictureServerType) -> String {
        return "picture_server_icon_\(type.rawValue)"
    }
    
    static func getIconByType(type: PictureServerType) -> NSImage {
        let iconName = PictureServer.getIconNameByType(type: type)
        return NSImage(named: iconName)!
    }
    
    let id: String
    var name: String
    let type: PictureServerType
    let isAnonymity: Bool
    var data: Any?
    
    init(_ name: String, type: PictureServerType, isAnonymity: Bool, data: Any?) {
        self.id = Date().milliStamp
        self.name = name
        self.type = type
        self.isAnonymity = isAnonymity
        self.data = data
    }
    
    public var debugDescription: String {
        return name + " " + "Type: \(type.rawValue)" + " Data: \(data.debugDescription)"
    }
}


public enum PictureServerType: String {
    case smms
    case qiniu
    case up
    case ali
    case tencent
}
