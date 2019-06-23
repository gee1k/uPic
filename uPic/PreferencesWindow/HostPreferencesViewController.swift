//
//  HostPreferencesViewController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//
import Cocoa
import ServiceManagement
import SwiftyJSON

class HostPreferencesViewController: PreferencesViewController {

    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!

    @IBOutlet weak var addHostButton: NSPopUpButton!
    @IBOutlet weak var removeHostButton: NSButton!
    @IBOutlet weak var editHostButton: NSButton!

    @IBOutlet weak var configView: NSView!

    var hostItems: [Host]?

    /* Obserber start */
    var hostItemsChanged = false
    {
        didSet {
            self.refreshButtonStatus()
        }
    }

    /* Obserber start */
    var selectedRow: Int = -1
    {
        didSet {
            self.refreshButtonStatus()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.target = self
        tableView.action = #selector(tableViewClick(_:))

        tableView.dataSource = self
        tableView.delegate = self

        self.initAddHostTypes()

        self.initHostItems()
        self.refreshButtonStatus()

        self.addObserver()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.removeObserver()
    }


    @IBAction func addHostButtonClicked(_ sender: NSPopUpButton) {
        guard let selectedItem = self.addHostButton.selectedItem else {
            return
        }
        let type: HostType = HostType(rawValue: selectedItem.tag)!
        self.addHost(type: type)
    }

    @IBAction func removeHostButoonClicked(_ sender: NSButton) {
        guard self.selectedRow > -1 else {
            return
        }

        self.deleteHost(index: self.selectedRow)
    }

    @IBAction func editHostButoonClicked(_ sender: NSButton) {
        guard self.selectedRow > -1 else {
            return
        }

        self.tableView.editColumn(0, row: self.selectedRow, with: nil, select: true)
    }

    //
    // save host config
    //
    @IBAction func saveButtonClicked(_ sender: Any?) {
        // TODO: 保存当前图床信息到用户配置文件
        ConfigManager.shared.setHostItems(items: self.hostItems!)
        self.hostItemsChanged = false
    }

    //
    // reset host config
    //
    @IBAction func resetButtonClicked(_ sender: NSButton) {
        // TODO: 从用户配置文件读取图床信息覆盖掉现有修改
        self.initHostItems()
        self.hostItemsChanged = false
    }

    @objc func tableViewClick(_ sender: Any) {
        configView.subviews.removeAll()
        self.selectedRow = tableView.selectedRow
        guard tableView.selectedRow >= 0, let item = hostItems?[tableView.selectedRow] else {
            return
        }

        switch item.type {
        case .upyun_USS:
            configView.addSubview(UpYunConfigView(frame: configView.frame, data: item.data))
            break
        case .qiniu_KODO:
            configView.addSubview(QiniuConfigView(frame: configView.frame, data: item.data))
            break
        default:
            let label = NSTextField(labelWithString: "文件将匿名上传至 \(item.name)")
            label.frame = NSRect(x: (configView.frame.width - label.frame.width) / 2, y: configView.frame.height - 50, width: label.frame.width, height: 20)
            configView.addSubview(label)
        }
    }

    func initHostItems() -> Void {
        self.hostItems = ConfigManager.shared.getHostItems()
        if self.hostItems?.count == 0 {
            self.hostItems?.append(Host.getDefaultHost())
            self.saveButtonClicked(nil)
            self.resetDefaultHostTypeVisible()
        }
        self.tableView.reloadData()

    }

    func initAddHostTypes() {
        for type in HostType.allCases {
            let menuItem = NSMenuItem(title: type.name, action: nil, keyEquivalent: "")
            menuItem.image = Host.getIconByType(type: type)
            menuItem.tag = type.rawValue
            addHostButton.menu?.addItem(menuItem)
        }
        self.resetDefaultHostTypeVisible()
    }

    // 设置添加默认图床是否可以显示
    func resetDefaultHostTypeVisible() -> Void {
        guard let hostItems = hostItems else {
            return
        }
        var hasDefaultHost = false
        for host in hostItems {
            if host.type == HostType.smms {
                hasDefaultHost = true
                break
            }
        }

        for item in addHostButton.menu!.items {
            if item.tag != HostType.smms.rawValue {
                continue
            }
            item.isHidden = hasDefaultHost
        }
    }

    func refreshButtonStatus() {
        self.saveButton.isEnabled = self.hostItemsChanged
        self.resetButton.isEnabled = self.hostItemsChanged

        let isSelected = self.selectedRow > -1
        self.removeHostButton.isEnabled = isSelected
        self.editHostButton.isEnabled = isSelected
    }


    func addHost(type: HostType) {
        let data = HostConfig.create(type: type)
        self.hostItems?.append(Host(type, data: data))
        self.tableView.reloadData()
        self.hostItemsChanged = true
        self.resetDefaultHostTypeVisible()
        
        self.selectedRow = (self.hostItems?.count ?? 0) - 1
        self.tableView.selectRowIndexes(IndexSet([self.selectedRow]), byExtendingSelection: false)
        self.tableViewClick(self)
    }

    func deleteHost(index: Int) {
        // Delete selected row
        self.tableView.removeRows(at: IndexSet([index]), withAnimation: .slideUp)
        // Delete the selected row data source
        self.hostItems?.remove(at: index)

        self.hostItemsChanged = true
        self.resetDefaultHostTypeVisible()
        
        selectedRow = -1
        self.tableViewClick(self)
    }

    func setHostName(index: Int, name: String) {
        if self.hostItems?[index].name != name {
            self.hostItems?[index].name = name
            self.hostItemsChanged = true
        }
    }

    func setHostData(index: Int, data: HostConfig?) {
        self.hostItems?[index].data = data
        self.hostItemsChanged = true
    }


    @objc func hostConfigChanged() {
        self.hostItemsChanged = true
    }

    func addObserver() {
        PreferencesNotifier.addObserver(observer: self, selector: #selector(hostConfigChanged), notification: .hostConfigChanged)
    }

    func removeObserver() {
        PreferencesNotifier.removeObserver(observer: self, notification: .hostConfigChanged)
    }
}


extension HostPreferencesViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return hostItems?.count ?? 0
    }

}

extension HostPreferencesViewController: NSTableViewDelegate {

    fileprivate enum CellIdentifiers {
        static let ServerCell = "ServerCellID"
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""

        guard let item = hostItems?[row] else {
            return nil
        }

        if tableColumn == tableView.tableColumns[0] {
            image = Host.getIconByType(type: item.type)
            text = item.name
            cellIdentifier = CellIdentifiers.ServerCell
        }

        if let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {

            cellView.appearance = tableView.appearance
            cellView.imageView?.image = image ?? nil
            cellView.textField?.stringValue = text
            cellView.textField?.isEditable = true
            cellView.textField?.font = NSFont.systemFont(ofSize: 14, weight: NSFont.Weight.medium)
            cellView.textField?.isBordered = false
            cellView.textField?.delegate = self

            return cellView
        }
        return nil
    }

}

extension HostPreferencesViewController: NSTextFieldDelegate {
    // 监听表格单元格（图床名称）修改完成
    func controlTextDidEndEditing(_ notification: Notification) {
        let textField = notification.object as! NSTextField
        let index = self.tableView.selectedRow

        if index > -1 {
            self.setHostName(index: index, name: textField.stringValue)
        }
    }
}
