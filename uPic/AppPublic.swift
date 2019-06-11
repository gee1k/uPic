//
//  Util.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/9.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

func getAppInfo() -> String {
    let infoDic = Bundle.main.infoDictionary
    let appNameStr = NSLocalizedString("app-name", comment: "APP 名称")
    let versionStr = infoDic?["CFBundleShortVersionString"] as! String
    return appNameStr + " v" + versionStr
}

func alertInfo(withText: String, withMessage: String) {
    let alert = NSAlert()
    alert.messageText = withText
    alert.informativeText = withMessage
    alert.addButton(withTitle: NSLocalizedString("general.ok", comment: "确定"))
    alert.window.titlebarAppearsTransparent = true
    alert.runModal()
}

func alertInfo(withText messageText: String, withMessage message: String, oKButtonTitle: String, cancelButtonTitle: String, okHandler:@escaping (()-> Void)) {
    let alert = NSAlert()
    alert.alertStyle = NSAlert.Style.informational
    alert.messageText = messageText
    alert.informativeText = message
    alert.addButton(withTitle: oKButtonTitle)
    alert.addButton(withTitle: cancelButtonTitle)
    alert.window.titlebarAppearsTransparent = true
    if alert.runModal() == .alertFirstButtonReturn {
        okHandler()
    }
}

// 垂直居中
class VerticallyCenteredTextFieldCell: NSTextFieldCell {
    
    override func drawingRect(forBounds theRect: NSRect) -> NSRect {
        var newRect:NSRect = super.drawingRect(forBounds: theRect)
        let textSize:NSSize = self.cellSize(forBounds: theRect)
        let heightDelta:CGFloat = newRect.size.height - textSize.height
        if heightDelta > 0 {
            newRect.size.height -= heightDelta
            newRect.origin.y += heightDelta/2
        }
        return newRect
    }
}


extension Date {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}



public enum BoolType: String {
    case _true
    case _false
    
    public var bool: Bool {
        get {
            return self == ._true
        }
        
        set {
            self = newValue ? ._true : ._false
        }
    }
}


class DefaultsKeys {
    fileprivate init() {}
}

class DefaultsKey<ValueType>: DefaultsKeys {
    let _key: String
    
    init(_ key: String) {
        self._key = key
    }
    
}


extension DefaultsKeys {
    
    // The values corresponding to the following keys are String.
    
    // value example: BoolType._true.rawValue
    static let firstUsage = DefaultsKey<String>(Constants.DefaultsKey.firstUsage)
    static let launchAtLogin = DefaultsKey<String>(Constants.DefaultsKey.launchAtLogin)
    
}

let Defaults = UserDefaults.standard

extension UserDefaults {
    subscript(key: DefaultsKey<String>) -> String? {
        get { return string(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
}
