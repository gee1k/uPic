//
//  CoreManager.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa
import ServiceManagement

public class ConfigManager {

    // static
    public static var shared = ConfigManager()

    // instance

    public var firstUsage: BoolType {
        if Defaults[.firstUsage] == nil {
            Defaults[.firstUsage] = BoolType._false.rawValue
            return ._true
        } else {
            return ._false
        }
    }

    public var launchAtLogin: BoolType? {
        get {
            return Defaults[.launchAtLogin].map(BoolType.init(rawValue:)) ?? nil
        }

        set {
            Defaults[.launchAtLogin] = newValue?.rawValue
            
            SMLoginItemSetEnabled(Constants.launcherAppIdentifier as CFString, newValue?.bool ?? false)
        }
    }
    
    public func firstSetup() {
        guard firstUsage == ._true else {
            return
        }
        Defaults[.launchAtLogin] = BoolType._false.rawValue
        Defaults[.compressFactor] = 100
        Defaults.synchronize()
        
        self.setHostItems(items: [Host.getDefaultHost()])
    }

    public func removeAllUserDefaults() {
        // 提前取出图床配置
        let hostItems = self.getHostItems()
        let domain = Bundle.main.bundleIdentifier!
        Defaults.removePersistentDomain(forName: domain)
        // 清除所有用户设置后，再重新写入图床配置
        self.setHostItems(items: hostItems)
        Defaults.synchronize()
    }

}


extension ConfigManager {
    // MARK: 图床配置和默认图床
    
    func getHostItems() -> [Host] {
        return Defaults[.hostItems] ?? [Host]()
    }
    
    func setHostItems(items: [Host]) -> Void {
        Defaults[.hostItems] = items
        Defaults.synchronize()
        ConfigNotifier.postNotification(.changeHostItems)
    }
    
    
    func getDefaultHost() -> Host? {
        guard let defaultHostId = Defaults[.defaultHostId], let hostItems = Defaults[.hostItems] else {
            return nil
        }
        for host in hostItems {
            if host.id == defaultHostId {
                return host
            }
        }
        return nil
    }
}


extension ConfigManager {
    // MARK: 上传历史
    
    public var historyLimit: Int {
        get {
            let defaultLimit = 10
            let limit =  Defaults[.historyLimit]
            if (limit == nil || limit == 0) {
                return defaultLimit
            }
            return limit!
        }
        
        set {
            Defaults[.historyLimit] = newValue
        }
    }
    
    func getHistoryList() -> [String] {
        return Defaults[.historyList] ?? [String]()
    }
    
    func setHistoryList(items: [String]) -> Void {
        Defaults[.historyList] = items
        Defaults.synchronize()
        ConfigNotifier.postNotification(.changeHistoryList)
    }
    
    func addHistory(url: String) -> Void {
        var list = self.getHistoryList()
        list.append(url)
        
        if list.count > self.historyLimit {
            list.removeFirst(list.count - self.historyLimit)
        }
        
        self.setHistoryList(items: list)
    }
    
    func clearHistoryList() -> Void {
        self.setHistoryList(items: [])
    }
}

extension ConfigManager {
    // MARK: 上传前压缩图片，压缩率
    var compressFactor: Int {
        get {
            return Defaults[.compressFactor] ?? 100
        }
        
        set {
            Defaults[.compressFactor] = newValue
            Defaults.synchronize()
        }
    }
}

extension ConfigManager {
    // import & export config
    
    func importHosts() {
        NSApp.activate(ignoringOtherApps: true)
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.allowedFileTypes = ["json"]
        
        openPanel.begin { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                guard let url = openPanel.url,
                    let data = NSData(contentsOfFile: url.path),
                    let array = try? JSONSerialization.jsonObject(with: data as Data) as? [String]
                    else {
                        NotificationExt.shared.postImportErrorNotice()
                        return
                }
                let hostItems = array.map(){ str in
                    return Host.deserialize(str: str)
                    }.filter { $0 != nil }
                if hostItems.count == 0 {
                    NotificationExt.shared.postImportErrorNotice()
                    return
                }
                
                // choose import method
                
                let alert = NSAlert()
                
                alert.messageText = NSLocalizedString("alert.import_hosts_title", comment: "")
                alert.informativeText = NSLocalizedString("alert.import_hosts_description", comment: "")
                
                alert.addButton(withTitle: NSLocalizedString("alert.import_hosts_merge", comment: "")).refusesFirstResponder = true
                
                alert.addButton(withTitle: NSLocalizedString("alert.import_hosts_overwrite", comment: "")).refusesFirstResponder = true
                
                let modalResult = alert.runModal()
                
                switch modalResult {
                case .alertFirstButtonReturn:
                    // current Items
                    var currentHostItems = ConfigManager.shared.getHostItems()
                    for host in hostItems {
                        let isContains = currentHostItems.contains(where: {item in
                            return item == host
                        })
                        if (!isContains) {
                            currentHostItems.append(host!)
                        }
                    }
                    ConfigManager.shared.setHostItems(items: currentHostItems)
                    NotificationExt.shared.postImportSuccessfulNotice()
                case .alertSecondButtonReturn:
                    ConfigManager.shared.setHostItems(items: hostItems as! [Host])
                    NotificationExt.shared.postImportSuccessfulNotice()
                default:
                    print("Cancel Import")
                }
            }
        }
    }
    
    func exportHosts() {
        let hostItems = ConfigManager.shared.getHostItems()
        if hostItems.count == 0 {
            NotificationExt.shared.postExportErrorNotice(NSLocalizedString("notification.export.error.body.no-hosts", comment: ""))
            return
        }
        
        NSApp.activate(ignoringOtherApps: true)
        let savePanel = NSSavePanel()
        savePanel.directoryURL = URL(fileURLWithPath: NSHomeDirectory().appendingPathComponent(path: "Documents"))
        savePanel.nameFieldStringValue = "uPic_hosts.json"
        savePanel.allowsOtherFileTypes = false
        savePanel.isExtensionHidden = true
        savePanel.canCreateDirectories = true
        savePanel.allowedFileTypes = ["json"]
        
        savePanel.begin { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                
                guard let url = savePanel.url else {
                    NotificationExt.shared.postImportErrorNotice()
                    return
                }
                
                let hostStrArr = hostItems.map(){ hostItem in
                    return hostItem.serialize()
                }
                if (!JSONSerialization.isValidJSONObject(hostStrArr)) {
                    NotificationExt.shared.postImportErrorNotice()
                    return
                }
                let os = OutputStream(toFileAtPath: url.path, append: false)
                os?.open()
                JSONSerialization.writeJSONObject(hostStrArr, to: os!, options: .prettyPrinted, error: .none)
                os?.close()
                NotificationExt.shared.postExportSuccessfulNotice()
            }
        }
    }
}
