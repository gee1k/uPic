//
//  Util.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/16.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

func getFileMd5(filePath: String) -> String? {
    guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
        return nil
    }
    let data = fileHandle.readDataToEndOfFile()
    return data.toMd5()
}

func getFileMd5(fileUrl: URL) -> String? {
    guard let fileHandle = try? FileHandle(forReadingFrom: fileUrl) else {
        return nil
    }
    let data = fileHandle.readDataToEndOfFile()
    return data.toMd5()
    
}

//根据后缀获取对应的Mime-Type
func getMimeType(pathExtension: String) -> String {
    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                       pathExtension as NSString,
                                                       nil)?.takeRetainedValue() {
        if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?
            .takeRetainedValue() {
            return mimetype as String
        }
    }
    //文件资源类型如果不知道，传万能类型application/octet-stream，服务器会自动解析文件类
    return "application/octet-stream"
}
