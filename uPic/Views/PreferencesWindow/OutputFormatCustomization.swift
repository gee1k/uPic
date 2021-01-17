//
//  OutputFormatCustomization.swift
//  uPic
//
//  Created by Licardo on 2021/1/17.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa

class OutputFormatCustomization: NSViewController {
    @IBOutlet var tableView: NSTableView!
    
    var nameTextField: NSTextField!
    var customStyleTextField: NSTextField!
    var deleteButton: NSButton!
    
    var item = ["1", "2", "3", "4", "5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func didClickAddButton(_ sender: NSButton) {
        item.append("")
        tableView.reloadData()
    }

    @IBAction func didClickCancelButton(_ sender: NSButton) {
        dismiss(sender)
    }

    @IBAction func didClickSaveButton(_ sender: NSButton) {
        dismiss(sender)
    }
}

// MARK: - DataSource

extension OutputFormatCustomization: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        item.count
    }
}

// MARK: - Delegate

extension OutputFormatCustomization: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "name"): // 自定义格式的名称
            nameTextField = NSTextField()
            nameTextField.bezelStyle = .roundedBezel
            nameTextField.stringValue = item[row]
            return nameTextField
        case NSUserInterfaceItemIdentifier(rawValue: "customStyle"): // 自定义格式的内容
            customStyleTextField = NSTextField()
            customStyleTextField.bezelStyle = .roundedBezel
            customStyleTextField.stringValue = item[row]
            return customStyleTextField
        case NSUserInterfaceItemIdentifier(rawValue: "delete"): // 删除按钮
            deleteButton = NSButton()
            deleteButton.bezelStyle = .rounded
            deleteButton.image = NSImage(named: NSImage.removeTemplateName)
            deleteButton.imagePosition = .imageOnly
            deleteButton.addTarget { _ in
                self.item.remove(at: row)
                self.tableView.reloadData()
            }
            return deleteButton
        default:
            return nil
        }
    }
}
