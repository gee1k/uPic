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

func getSystemVersionString() -> String {
    return ProcessInfo.processInfo.operatingSystemVersionString
}

func getAppVersionString() -> String {
    let versionNum = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let buildNum = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    return "v\(versionNum) (\(buildNum))"
}

func getModelIdentifier() -> String {
    #if os(iOS)
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let modelIdentifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return modelIdentifier

    #else
    var modelIdentifier: String?
    let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
    if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
        modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
    }
    IOObjectRelease(service)
    return modelIdentifier ?? "Mac"

    #endif
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


func debugPrintOnly(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    debugPrint(items, separator: separator, terminator: terminator)
    #endif
}
