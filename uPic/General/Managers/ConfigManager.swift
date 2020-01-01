//
//  CoreManager.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa
import LoginServiceKit

public class ConfigManager {
    
    // static
    public static var shared = ConfigManager()
    // instance
    
    var historyList: [HistoryThumbnailModel]!
    
    public var firstUsage: BoolType {
        if Defaults[.firstUsage] == nil {
            Defaults[.firstUsage] = BoolType._false.rawValue
            return ._true
        } else {
            return ._false
        }
    }
    
    public func firstSetup() {
        // Cahce history list
        let _ = getHistoryList()
        
        guard firstUsage == ._true else {
            return
        }
        Defaults[.compressFactor] = 100
        Defaults.synchronize()
        
        self.setHostItems(items: [Host.getDefaultHost()])
        
        LoginServiceKit.removeLoginItems()
    }
    
    
    public func removeAllUserDefaults() {
        // 提前取出图床配置
        let hostItems = self.getHostItems()
        let defaultHostId = Defaults[.defaultHostId]
        
        let domain = Bundle.main.bundleIdentifier!
        Defaults.removePersistentDomain(forName: domain)
        Defaults.synchronize()
        
        DispatchQueue.main.async {
            // 清除所有用户设置后，再重新写入图床配置
            self.setHostItems(items: hostItems)
            Defaults[.defaultHostId] = defaultHostId
        }
    }
    
}

// MARK: - Host configuration and default host
extension ConfigManager {
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
    func getOutputType() -> OutputType {
        return OutputType(value: Defaults[.ouputFormat])
    }
    
    func setOutputType(_ outputType: OutputType) {
        Defaults[.ouputFormat] = outputType.rawValue
    }
    
    func setOutputType(_ outputTypeRawValue: Int) {
        Defaults[.ouputFormat] = outputTypeRawValue
    }
}

// MARK: - Upload history
extension ConfigManager {
    public var historyLimit: Int {
        get {
            let defaultLimit = 100
            let limit = Defaults[.historyLimit]
            if (limit == nil || limit == 0) {
                return defaultLimit
            }
            return limit!
        }
        
        set {
            Defaults[.historyLimit] = newValue
            Defaults.synchronize()
        }
    }
    
    func getHistoryList() -> [HistoryThumbnailModel] {
        if historyList != nil {
            return historyList
        }
        
        // FIXME: - workaround 转移旧版历史记录到 db
        if let historyList = Defaults[.historyList] {
            let oldHistoryListModel: [HistoryThumbnailModel] = historyList.map({ (item) -> HistoryThumbnailModel in
               return HistoryThumbnailModel.keyValue(keyValue: item)
            })

            DBManager.shared.insertHistorys(oldHistoryListModel)
            Defaults.removeObject(forKey: Keys.historyList)
        }

        historyList = DBManager.shared.getHistoryList()
        return historyList
    }
    
    func addHistory(_ previewModel: HistoryThumbnailModel) -> Void {
        historyList.insert(previewModel, at: 0)
        let offset = historyList.count - self.historyLimit
        if offset > 0 {
            // Because the results of the query are already sorted backwards, the first is the last
            historyList.removeLast(offset)
        }
        DispatchQueue.global().async {
            if offset > 0 {
                DBManager.shared.deleteHositoryFirst(offset)
            }
            DBManager.shared.insertHistory(previewModel)
        }
        ConfigNotifier.postNotification(.updateHistoryList)
    }
    
    func clearHistoryList() -> Void {
        historyList.removeAll()
        DispatchQueue.global().async {
            DBManager.shared.clearHistory()
        }
        ConfigNotifier.postNotification(.updateHistoryList)
    }
}

// MARK: - Compression ratio of compressed images before upload
extension ConfigManager {
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
// MARK: - Import, Export host configuretion
extension ConfigManager {
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
