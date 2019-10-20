//
//  Util.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/9.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON

func getAppInfo() -> String {
    let infoDic = Bundle.main.infoDictionary
    let appNameStr = "APP Name".localized
    let versionStr = infoDic?["CFBundleShortVersionString"] as! String
    return appNameStr + " v" + versionStr
}

func alertInfo(withText: String, withMessage: String) {
    let alert = NSAlert()
    alert.messageText = withText
    alert.informativeText = withMessage
    alert.addButton(withTitle: "OK".localized)
    alert.window.titlebarAppearsTransparent = true
    alert.runModal()
}

func alertInfo(withText messageText: String, withMessage message: String, oKButtonTitle: String, cancelButtonTitle: String, okHandler: @escaping (() -> Void)) {
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
