//
//  PictureServerPreferencesViewController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//
import Cocoa
import ServiceManagement

class PictureServerPreferencesViewController: PreferencesViewController {
    
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    var pictureServerItems: [PictureServer]?
    var pictureServerItemsChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pictureServerItems = Array<PictureServer>()
        pictureServerItems?.append(PictureServer("smms", type: PictureServerType.smms, isAnonymity: true, data: nil))
        pictureServerItems?.append(PictureServer("smms", type: PictureServerType.smms, isAnonymity: true, data: nil))
        
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        tableView.dataSource = self
        tableView.delegate = self
        self.refreshButtonStatus()

    }
    
    @objc func tableViewDoubleClick(_ sender: Any) {
        guard tableView.selectedRow >= 0, let item = pictureServerItems?[tableView.selectedRow] else {
            return
        }
        
        
        debugPrint(item)
    }
    
    @IBAction func saveButtonClicked(_ sender: NSButton) {
        // TODO: 保存当前图床信息到用户配置文件
    }
    
    @IBAction func resetButtonClicked(_ sender: NSButton) {
        // TODO: 从用户配置文件读取图床信息覆盖掉现有修改
    }
    
    func setPictureServerItemsChanged(isChanged: Bool) {
        self.pictureServerItemsChanged = isChanged
        self.refreshButtonStatus()
    }
    
    func refreshButtonStatus() {
        self.saveButton.isEnabled = self.pictureServerItemsChanged
        self.resetButton.isEnabled = self.pictureServerItemsChanged
    }
    
}


extension PictureServerPreferencesViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return pictureServerItems?.count ?? 0
    }
    
}

extension PictureServerPreferencesViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let ServerCell = "ServerCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = pictureServerItems?[row] else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            image = PictureServer.getIconByType(type: item.type)
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

extension PictureServerPreferencesViewController: NSTextFieldDelegate {
    // 监听表格单元格（图床名称）修改完成
    func controlTextDidEndEditing(_ notification: Notification) {
        let textField = notification.object as! NSTextField
        let index = tableView.selectedRow
        
        if index > -1 {
            
            debugPrint(textField.stringValue)
            
            self.pictureServerItems?[index].name = textField.stringValue
            
            self.setPictureServerItemsChanged(isChanged: true)
        }
    }
}
