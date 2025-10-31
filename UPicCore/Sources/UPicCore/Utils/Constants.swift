//
//  Constants.swift
//  Alamofire
//
//  Created by Svend Jin on 2020/1/9.
//

import Foundation

public class UPicCoreConstants {
    public static let DEFAULT_SAVE_KEY_PATH: String = "{filename}{.suffix}"
    public static let SAVE_KEY_TEMPLATES: [String] = ["{filename}", "{.suffix}", "{year}", "{month}", "{day}", "{hour}", "{minute}", "{second}", "{since_second}", "{since_millisecond}", "{random}"]
    public static let CUSTOM_HEADER_BODY_TEMPLATES: [String] = {
        var ret = SAVE_KEY_TEMPLATES
        ret.insert("{saveKey}", at: 0)
        return ret
    }()
}
