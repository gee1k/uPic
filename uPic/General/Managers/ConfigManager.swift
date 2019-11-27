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
        Defaults[.compressFactor] = Int(100)
        Defaults[.historyRecordWidth] = Float(500)
        Defaults[.historyRecordColumns] = Int(3)
        Defaults[.historyRecordSpacing] = Float(5)
        Defaults[.historyRecordPadding] = Float(5)
        Defaults[.historyRecordFileNameScrollSpeed] = Double(30)
        Defaults[.historyRecordFileNameScrollWaitTime] = Float(1)
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
    
    public var historyLimit_New: Int {
        get {
            let defaultLimit = 100
            let limit = Defaults[.historyLimit_New]
            if (limit == nil || limit == 0) {
                return defaultLimit
            }
            return limit!
        }
        
        set {
            Defaults[.historyLimit_New] = newValue
            Defaults.synchronize()
        }
    }
    
    func getHistoryList_New() -> [HistoryThumbnailModel] {
        let historyList = Defaults[.historyList_New] ?? [[String: Any]]()
        let historyListModel: [HistoryThumbnailModel] = historyList.map({ (item) -> HistoryThumbnailModel in
            return HistoryThumbnailModel.keyValue(keyValue: item)
        })
        return historyListModel
    }
    
    func setHistoryList_New(items: [[String: Any]]) -> Void {
        Defaults[.historyList_New] = items
        Defaults.synchronize()
        ConfigNotifier.postNotification(.updateHistoryList)
    }
    
    func addHistory_New(url: String, previewModel: HistoryThumbnailModel) -> Void {
        var list = self.getHistoryList_New().map { (model) -> [String: Any] in
            return model.toKeyValue()
        }
        list.insert(previewModel.toKeyValue(), at: 0)
        
        if list.count > self.historyLimit_New {
            list.removeFirst(list.count - self.historyLimit_New)
        }
        
        self.setHistoryList_New(items: list)
    }
    
    func clearHistoryList_New() -> Void {
        self.setHistoryList_New(items: [])
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
                
                alert.messageText = "Import host configuration".localized
                alert.informativeText = "⚠️ Please choose import method, merge or overwrite?".localized
                
                alert.addButton(withTitle: "merge".localized).refusesFirstResponder = true
                
                alert.addButton(withTitle: "⚠️ overwrite".localized).refusesFirstResponder = true
                
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
            NotificationExt.shared.postExportErrorNotice("No exportable hosts!".localized)
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
