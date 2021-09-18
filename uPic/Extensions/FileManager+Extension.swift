//
//  FileManagerExtension.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/26.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

extension FileManager {
    // 判断是否是文件夹的方法
    static func directoryIsExists (path: String) -> Bool {

        var directoryExists = ObjCBool.init(false)

        let fileExists = FileManager.default.fileExists(atPath: path, isDirectory: &directoryExists)

        return fileExists && directoryExists.boolValue

    }
    
    // 判断是否是文件的方法
    static func fileIsExists (path: String) -> Bool {

        var directoryExists = ObjCBool.init(false)

        let fileExists = FileManager.default.fileExists(atPath: path, isDirectory: &directoryExists)

        return fileExists && !directoryExists.boolValue

    }
}
