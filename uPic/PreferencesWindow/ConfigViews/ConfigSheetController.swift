//
//  ConfigViewController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/19.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class ConfigSheetController: NSViewController {

    @IBOutlet weak var domainTextField: NSTextField!
    @IBOutlet weak var folderTextField: NSTextField!
    @IBOutlet weak var saveKeyPopUpButton: NSPopUpButton!
    @IBOutlet weak var previewLabel: NSTextField!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var okButton: NSButton!

    var saveKey: HostSaveKey!
    let testFilename = "uPic"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        okButton.highlight(true)
    }

    @IBAction func onTextChanged(_ sender: NSTextField) {
        self.resetPreviewLabel()
    }

    @IBAction func onSaveKeyChanged(_ sender: NSPopUpButton) {
        self.resetPreviewLabel()
    }

    @IBAction func okBtnClicked(_ sender: Any) {
        let userInfo: [String: Any] = ["domain": self.domainTextField.stringValue, "folder": self.folderTextField.stringValue, "saveKey": saveKeyPopUpButton.selectedItem?.identifier?.rawValue ?? HostSaveKey.dateFilename.rawValue]
        PreferencesNotifier.postNotification(.saveHostSettings, object: "ConfigSheetController", userInfo: userInfo)

        self.dismiss(sender)
    }

    func resetSaveKeyPopUp() {
        saveKeyPopUpButton.menu?.removeAllItems()
        var itemIndex = -1
        for (index, key) in HostSaveKey.allCases.enumerated() {
            let menuItem = NSMenuItem(title: key.name, action: nil, keyEquivalent: "")
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: key.rawValue)
            saveKeyPopUpButton.menu?.addItem(menuItem)
            if key == self.saveKey {
                itemIndex = index
            }
        }

        if itemIndex > -1 {
            saveKeyPopUpButton.selectItem(at: itemIndex)
        }
    }

    func resetPreviewLabel() {
        var text = "示例："
        if (domainTextField.stringValue.count > 0) {
            text += domainTextField.stringValue
        }
        if (folderTextField.stringValue.count > 0) {
            text += "/\(folderTextField.stringValue)"
        }
        if let selectedItem = saveKeyPopUpButton.selectedItem, let identifier = selectedItem.identifier {
            let key = HostSaveKey(rawValue: identifier.rawValue)!
            text += "/\(key.getFileName(filename: testFilename))"
        } else {
            text += "/\(HostSaveKey.random.getFileName(filename: testFilename))"
        }
        previewLabel.stringValue = "\(text).jpg"
    }

    func setData(userInfo: [String: AnyObject]) {

        let domain = userInfo["domain"] as! String
        let folder = userInfo["folder"] as! String
        let saveKey = userInfo["saveKey"] as! String

        domainTextField.stringValue = domain
        folderTextField.stringValue = folder

        self.saveKey = HostSaveKey(rawValue: saveKey)

        self.resetSaveKeyPopUp()
        self.resetPreviewLabel()
    }

}
