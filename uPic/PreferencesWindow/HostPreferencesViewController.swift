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
    
    // 配置更改状态变化节流函数
    var hostConfigChangedDebouncedFunc: CancelAction!

    /* Obserber start */
    var hostItemsChanged = false {
        didSet {
            self.refreshButtonStatus()
        }
    }
    
    /* Obserber start */
    var selectedRow: Int = -1 {
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
        
        self.resetAllowOnlyOneHostTypeVisible()
        
        self.selectedRow = 0
        self.setDefaultSelectedHost()
    }


    override func viewDidAppear() {
        super.viewDidAppear()

        self.setDefaultSelectedHost()

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
        
        guard let type: HostType = HostType(rawValue: selectedItem.tag) else {
            return
        }
        
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
        
        // 取消一下节流函数的定时器，确保不会在点击保存按钮后，再重新计划安装状态
        self.hostConfigChangedDebouncedFunc(true)
        
        // 先让当前正在编辑的输入框触发一下 editEnd 事件，来 trim 一下本身
        self.blurEditingTextField()
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

        // MARK: 根据当前选择的图床，创建对应的配置界面
        switch item.type {
        case .custom:
            configView.addSubview(CustomConfigView(frame: configView.frame, data: item.data))
            break
        case .upyun_USS:
            configView.addSubview(UpYunConfigView(frame: configView.frame, data: item.data))
            break
        case .qiniu_KODO:
            configView.addSubview(QiniuConfigView(frame: configView.frame, data: item.data))
            break
        case .aliyun_OSS:
            configView.addSubview(AliyunConfigView(frame: configView.frame, data: item.data))
            break
        case .tencent_COS:
            configView.addSubview(TencentConfigView(frame: configView.frame, data: item.data))
            break
        default:
            let label = NSTextField(labelWithString: NSLocalizedString("anonymously-upload", comment: "匿名上传") + " \(item.name)")
            label.frame = NSRect(x: (configView.frame.width - label.frame.width) / 2, y: configView.frame.height - 50, width: label.frame.width, height: 20)
            configView.addSubview(label)
        }
    }
    
    // MARK: 将正在编辑的输入框执行 endEdit
    func blurEditingTextField() {
        for view in self.configView.subviews {
            for subView in view.subviews {
                if !(subView is NSTextField) {
                    continue
                }
                if let subTextField = subView as? NSTextField, let editor = subTextField.currentEditor() {
                    subTextField.endEditing(editor)
                }
            }
        }
    }

    // MARK: 初始化用户的图床配置
    func initHostItems() -> Void {
        self.hostItems = ConfigManager.shared.getHostItems()
        if self.hostItems?.count == 0 {
            self.hostItems?.append(Host.getDefaultHost())
            self.saveButtonClicked(nil)
        }
        self.tableView.reloadData()

    }

    // MARK: 初始化图床添加按钮的子菜单
    func initAddHostTypes() {
        addHostButton.pullsDown = true
        addHostButton.removeAllItems()
        addHostButton.imagePosition = .imageOnly
        
        let imageItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        imageItem.image = NSImage(named: NSImage.addTemplateName)
        imageItem.identifier = NSUserInterfaceItemIdentifier(rawValue: "addImageTemplate")
        imageItem.isHidden = true
        addHostButton.menu?.addItem(imageItem)
        
        for type in HostType.allCases {
            let menuItem = NSMenuItem(title: type.name, action: nil, keyEquivalent: "")
            menuItem.image = Host.getIconByType(type: type)
            menuItem.tag = type.rawValue
            addHostButton.menu?.addItem(menuItem)
        }
        
    }

    // MARK: 设置只允许添加一个实例的图床添加按钮是否可用
    func resetAllowOnlyOneHostTypeVisible() -> Void {
        guard let hostItems = hostItems else {
            return
        }
        var onlyOneHosts = [Int]()
        for host in hostItems {
            if host.type.isOnlyOne {
                onlyOneHosts.append(host.type.rawValue)
            }
        }

        for item in addHostButton.menu!.items {
            // 隐藏只能有一个实例的类别。和用来显示 + 号的选项。注：明明在初始化时已经设置了，担不起作用。必须在过后设置才有用
            item.isHidden = onlyOneHosts.contains(item.tag) || item.identifier?.rawValue == "addImageTemplate"
        }
    }

    // MARK: 设置默认选中的图床配置
    func setDefaultSelectedHost() {
        self.tableView.selectRowIndexes(IndexSet([self.selectedRow]), byExtendingSelection: false)
        self.tableViewClick(self)
    }

    // MARK: 刷新按钮状态
    func refreshButtonStatus() {
        self.saveButton.isEnabled = self.hostItemsChanged
        self.resetButton.isEnabled = self.hostItemsChanged

        let isSelected = self.selectedRow > -1
        self.removeHostButton.isEnabled = isSelected
        self.editHostButton.isEnabled = isSelected
    }

    // MARK: 添加图床
    func addHost(type: HostType) {
        let data = HostConfig.create(type: type)
        data?.observerValues()
        self.hostItems?.append(Host(type, data: data))
        self.tableView.reloadData()
        self.hostItemsChanged = true
        self.resetAllowOnlyOneHostTypeVisible()

        self.selectedRow = (self.hostItems?.count ?? 0) - 1
        self.setDefaultSelectedHost()
    }

    // MARK: 删除图床
    func deleteHost(index: Int) {
        // Delete selected row
        self.tableView.removeRows(at: IndexSet([index]), withAnimation: .slideUp)
        // Delete the selected row data source
        self.hostItems?.remove(at: index)

        self.hostItemsChanged = true
        self.resetAllowOnlyOneHostTypeVisible()

        selectedRow = -1
        self.setDefaultSelectedHost()
    }

    // MARK: 修改图床名称
    func setHostName(index: Int, name: String) {
        if self.hostItems?[index].name != name {
            self.hostItems?[index].name = name
            self.hostItemsChanged = true
        }
    }


    @objc func hostConfigChanged() {
        hostConfigChangedDebouncedFunc(false)
    }

    func addObserver() {
        // 设置监听配置变化的节流函数，当0.5秒后没有再次变化就刷新当前状态
        hostConfigChangedDebouncedFunc = Util.debounce(threshold: 0.5) {
            DispatchQueue.main.async {
                self.hostItemsChanged = true
            }
            
        }
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
