//
//  DatabaseViewController.swift
//  uPic
//
//  Created by Licardo on 2021/1/13.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa

class DatabaseViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    
    var hostItems: [Host] = []
    var items: [HistoryThumbnailModel] = []
    var sortOrder: SortOrder = SortOrder.Name
    var selectedRow: Set<Int> = []
    var selectionDidChange = false
    var sortAscending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 打开偏好设置时在 Dock 栏显示应用图标，方便用户再次返回设置界面
        if NSApp.activationPolicy() == .accessory {
            NSApp.setActivationPolicy(.regular)
        }
        
        //enableCopyMenu()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.doubleAction = #selector(copyURL)
        
        // 获取图床信息
        hostItems = ConfigManager.shared.getHostItems()
        
        items = DBManager.shared.getHistoryList()
        sortConfig()
        tableView.reloadData()
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        
        let copyMenuItem = NSMenuItem()
        copyMenuItem.title = "Copy".localized + " (" + "\(selectedRow.count)" + "items".localized + ")"
        copyMenuItem.isEnabled = false
        copyMenuItem.action = #selector(copyURL)
        
        menu.addItem(copyMenuItem)
        
        NSMenu.popUpContextMenu(menu, with: event, for: tableView)
    }
    
    func enableCopyMenu() {
        if let mainMenu = NSApp.mainMenu, let editMenu = mainMenu.item(at: 2)?.submenu {
            for item in editMenu.items {
                if item.identifier?.rawValue == "copy" {
                    item.action = #selector(didClickCopyButton(_:))
                }
            }
        }
    }
    
    // 根据 ID 获取图床
    func getHostById(_ id: String?) -> Host? {
        guard let id = id else {
            return nil
        }
        return hostItems.first(where: {$0.id == id})
    }
    
    @IBAction func didClickRefreshButton(_ sender: NSToolbarItem) {
        items = DBManager.shared.getHistoryList()
        tableView.reloadData()
    }
    
    @IBAction func didClickCopyButton(_ sender: NSToolbarItem) {
        copyURL()
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
            tableView.reloadData()
        } else if response == .alertSecondButtonReturn {
            NSLog("Cancel")
        }
    }
    
    @objc func copyURL() {
        guard selectedRow.count > 0 else {
            return
        }
        var urls: [String] = []
        
        for row in selectedRow.sorted() {
            urls.append(items[row].url)
        }
        
        let outputUrl = (NSApplication.shared.delegate as? AppDelegate)?.copyUrls(urls: urls)
        NotificationExt.shared.postCopySuccessfulNotice(outputUrl)
    }
    
    func sortConfig() {
        let descriptorName = NSSortDescriptor(key: SortOrder.Name.rawValue, ascending: false)
        let descriptorHost = NSSortDescriptor(key: SortOrder.Host.rawValue, ascending: false)
        let descriptorSize = NSSortDescriptor(key: SortOrder.Size.rawValue, ascending: false)
        let descriptorTime = NSSortDescriptor(key: SortOrder.Time.rawValue, ascending: false)
        let descriptorURL = NSSortDescriptor(key: SortOrder.URL.rawValue, ascending: false)
        
        tableView.tableColumns[1].sortDescriptorPrototype = descriptorName
        tableView.tableColumns[2].sortDescriptorPrototype = descriptorHost
        tableView.tableColumns[3].sortDescriptorPrototype = descriptorSize
        tableView.tableColumns[4].sortDescriptorPrototype = descriptorTime
        tableView.tableColumns[5].sortDescriptorPrototype = descriptorURL
    }
    
    func sortTableView() {
        items = DBManager.shared.getHistoryList().sorted {
            switch sortOrder {
            case .Name:
                return sortAscending ? $0.fileName < $1.fileName : $0.fileName > $1.fileName
            case .Host:
                if let host0 = $0.host, let host1 = $1.host {
                    return sortAscending ? host0 < host1 : host0 > host1
                }
                return false
            case .Size:
                return sortAscending ? $0.size < $1.size : $0.size > $1.size
            case .Time:
                return sortAscending ? $0.createdDate < $1.createdDate : $0.createdDate > $1.createdDate
            case .URL:
                return sortAscending ? $0.url < $1.url : $0.url > $1.url
            }
        }
        
        tableView.reloadData()
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
        case NSUserInterfaceItemIdentifier(rawValue: "host"):
            cell?.imageView?.image = Host.getIconByType(type: getHostById(item.host)?.type ?? .smms)
        case NSUserInterfaceItemIdentifier(rawValue: "size"):
            cell?.textField?.stringValue = "\(ByteCountFormatter.string(fromByteCount: Int64(item.size), countStyle: .decimal))"
        case NSUserInterfaceItemIdentifier(rawValue: "time"):
            cell?.textField?.stringValue = item.createdDate.format()
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
        if tableView.selectedRow < 0 {
            selectedRow.removeAll()
        }
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
    case Host
    case Size
    case Time
    case URL
}
