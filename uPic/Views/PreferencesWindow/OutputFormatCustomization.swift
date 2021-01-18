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
    
    var items: [OutputFormatModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = DBManager.shared.getOutputFormatList()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func didClickAddButton(_ sender: NSButton) {
        items.append(OutputFormatModel(name: "Custom", value: "{url}"))
        tableView.reloadData()
    }

    @IBAction func didClickCancelButton(_ sender: NSButton) {
        dismiss(sender)
    }

    @IBAction func didClickSaveButton(_ sender: NSButton) {
        blurEditingTextField()
        DBManager.shared.saveOutputFormats(items)
        dismiss(sender)
    }
    
    // MARK: 将正在编辑的输入框执行 endEdit
    func blurEditingTextField() {
        for view in self.tableView.subviews {
            if !(view is NSTableRowView) {
                continue
            }
            for subView in view.subviews {
                if subView is NSTextField {
                    let subTextField = subView as! NSTextField
                    if let editor = subTextField.currentEditor() {
                        subTextField.endEditing(editor)
                    }
                }
                
            }
        }
    }
}

// MARK: - DataSource

extension OutputFormatCustomization: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        items.count
    }
}

// MARK: - Delegate

extension OutputFormatCustomization: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let NameCell = "name"
        static let ValueCell = "value"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        
        switch tableColumn?.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "name"): // 自定义格式的名称
            nameTextField = NSTextField()
            nameTextField.bezelStyle = .roundedBezel
            nameTextField.stringValue = items[row].name
            nameTextField.identifier = NSUserInterfaceItemIdentifier(rawValue: "name")
            nameTextField.tag = row
            nameTextField.delegate = self
            return nameTextField
        case NSUserInterfaceItemIdentifier(rawValue: "value"): // 自定义格式的内容
            customStyleTextField = NSTextField()
            customStyleTextField.bezelStyle = .roundedBezel
            customStyleTextField.stringValue = items[row].value
            customStyleTextField.identifier = NSUserInterfaceItemIdentifier(rawValue: "value")
            customStyleTextField.tag = row
            customStyleTextField.delegate = self
            return customStyleTextField
        case NSUserInterfaceItemIdentifier(rawValue: "delete"): // 删除按钮
            deleteButton = NSButton()
            deleteButton.bezelStyle = .rounded
            deleteButton.image = NSImage(named: NSImage.removeTemplateName)
            deleteButton.imagePosition = .imageOnly
            deleteButton.addTarget { _ in
                self.items.remove(at: row)
                self.tableView.reloadData()
            }
            return deleteButton
        default:
            return nil
        }
    }
}
extension OutputFormatCustomization: NSTextFieldDelegate {
    // 监听表格单元格（图床名称）修改完成
    func controlTextDidEndEditing(_ notification: Notification) {
        let textField = notification.object as! NSTextField
        
        guard let identifier = textField.identifier?.rawValue else {
            return
        }
        
        let item = self.items[textField.tag]
        
        switch identifier {
        case "name":
            item.name = textField.stringValue
            break
        case "value":
            item.value = textField.stringValue
            break
        default:
            break
        }
    }
}
