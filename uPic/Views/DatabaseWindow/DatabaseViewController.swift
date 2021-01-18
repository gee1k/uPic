//
//  DatabaseViewController.swift
//  uPic
//
//  Created by Licardo on 2021/1/13.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa

class DatabaseViewController: NSViewController {
    @IBOutlet weak var databaseTableView: NSTableView!
    
    var hostItems: [Host] = []
    var items: [HistoryThumbnailModel] = []
    var sortOrder: SortOrder = SortOrder.ID
    var selectedRow: Set<Int> = []
    var selectionDidChange = false
    var sortAscending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 打开偏好设置时在 Dock 栏显示应用图标，方便用户再次返回设置界面
        if NSApp.activationPolicy() == .accessory {
            NSApp.setActivationPolicy(.regular)
        }
        
        databaseTableView.dataSource = self
        databaseTableView.delegate = self
        
        
        // 获取图床信息
        hostItems = ConfigManager.shared.getHostItems()
        
        items = DBManager.shared.getHistoryList()
        sortConfig()
        databaseTableView.reloadData()
    }
    
    // 根据 ID 获取图床
    func getHostById(_ id: String)->Host? {
        return hostItems.first(where: {$0.id == id})
    }
    
    @IBAction func didClickRefreshButton(_ sender: NSToolbarItem) {
        items = DBManager.shared.getHistoryList()
        databaseTableView.reloadData()
    }
    
    @IBAction func didClickCopyButton(_ sender: NSToolbarItem) {
        var urls: [String] = []
        
        for row in selectedRow.sorted() {
            urls.append(items[row].url)
        }
        
        let outputUrl = (NSApplication.shared.delegate as? AppDelegate)?.copyUrls(urls: urls)
        NotificationExt.shared.postCopySuccessfulNotice(outputUrl)
    }
    
    @IBAction func didClickDeleteButton(_ sender: NSToolbarItem) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Warning".localized
        alert.informativeText = "⚠️ Note that this will clear your uPic database".localized
        alert.addButton(withTitle: "Continue".localized)
        alert.addButton(withTitle: "Cancel".localized)
        alert.window.titlebarAppearsTransparent = true
        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            ConfigManager.shared.clearHistoryList()
            items = ConfigManager.shared.getHistoryList()
            databaseTableView.reloadData()
        } else if response == .alertSecondButtonReturn {
            NSLog("Cancel")
        }
    }
    
    
    func sortConfig() {
        let descriptorName = NSSortDescriptor(key: SortOrder.Name.rawValue, ascending: true)
        let descriptorID = NSSortDescriptor(key: SortOrder.ID.rawValue, ascending: false)
        let descriptorURL = NSSortDescriptor(key: SortOrder.URL.rawValue, ascending: true)
        
        databaseTableView.tableColumns[1].sortDescriptorPrototype = descriptorName
        databaseTableView.tableColumns[2].sortDescriptorPrototype = descriptorID
        databaseTableView.tableColumns[3].sortDescriptorPrototype = descriptorURL
    }
    
    func sortTableView() {
        items = DBManager.shared.getHistoryList().sorted {
            switch sortOrder {
            case .Name:
                return sortAscending ? $0.fileName < $1.fileName : $0.fileName > $1.fileName
            case .ID:
                return sortAscending ? $0.identifier! < $1.identifier! : $0.identifier! > $1.identifier!
            case .URL:
                return sortAscending ? $0.url < $1.url : $0.url > $1.url
            }
        }
        
        databaseTableView.reloadData()
    }
    
}

// MARK: - DataSource
extension DatabaseViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        items.count
    }
}

// MARK: - Delegate

extension DatabaseViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = items[row]
        
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView
        
        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "index"):
            cell?.textField?.stringValue = String(row + 1)
        case NSUserInterfaceItemIdentifier(rawValue: "name"):
            cell?.textField?.stringValue = item.fileName
        case NSUserInterfaceItemIdentifier(rawValue: "id"):
            cell?.textField?.stringValue = String(item.identifier ?? 0)
        case NSUserInterfaceItemIdentifier(rawValue: "isImage"):
            cell?.textField?.stringValue = item.isImage ? "Yes".localized : "No".localized
        case NSUserInterfaceItemIdentifier(rawValue: "url"):
            cell?.textField?.stringValue = item.url
        case NSUserInterfaceItemIdentifier(rawValue: "review"):
            cell?.imageView?.image = item.isImage ? NSImage(data: item.thumbnailData!) : NSImage(named: "fileImage")
        default:
            cell?.textField?.stringValue = item.fileName
        }
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if selectionDidChange {
            selectedRow.removeAll()
        }
        
        selectedRow.insert(row)
        selectionDidChange = false
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectionDidChange = true
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        
        if let order = SortOrder(rawValue: sortDescriptor.key!) {
            sortOrder = order
            sortAscending = sortDescriptor.ascending
            sortTableView()
            
            print(order)
        }
    }
}

// MARK: - sort order
enum SortOrder: String {
    case Name
    case ID
    case URL
}
