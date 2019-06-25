//
//  Util.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/16.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

class Util {
    static func getFileMd5(filePath: String) -> String? {
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            return nil
        }
        let data = fileHandle.readDataToEndOfFile()
        return data.toMd5()
    }
    
    static func getFileMd5(fileUrl: URL) -> String? {
        guard let fileHandle = try? FileHandle(forReadingFrom: fileUrl) else {
            return nil
        }
        let data = fileHandle.readDataToEndOfFile()
        return data.toMd5()
        
    }
    
    //根据后缀获取对应的Mime-Type
    static func getMimeType(pathExtension: String) -> String {
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
    
    static func getCurrentLanguage() -> String {
        let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
        
        switch String(describing: preferredLang) {
        case "en-US", "en-CN":
            return "en"//英文
        case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
            return "cn"//中文
        default:
            return "en"
        }
    }
}
