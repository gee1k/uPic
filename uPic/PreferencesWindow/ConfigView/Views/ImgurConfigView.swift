//
//  ImgurConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/8/17.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class ImgurConfigView: ConfigView {
    
    override var paddingTop: Int {
        return 50
    }
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? ImgurHostConfig else {
            return
        }
        
      
        // MARK: clientId
        let clientIdLabel = NSTextField(labelWithString: "\(data.displayName(key: "clientId")):")
        clientIdLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        clientIdLabel.alignment = .right
        clientIdLabel.lineBreakMode = .byClipping
        
        let clientIdField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        clientIdField.identifier = NSUserInterfaceItemIdentifier(rawValue: "clientId")
        clientIdField.usesSingleLineMode = true
        clientIdField.lineBreakMode = .byTruncatingTail
        clientIdField.delegate = data
        clientIdField.stringValue = data.clientId ?? ""
        self.addSubview(clientIdLabel)
        self.addSubview(clientIdField)
        nextKeyViews.append(clientIdField)
        
        // Get Client ID
        
        y = y - gapTop - labelHeight
        
        
        
        let getClientIdBtn = NSButton(title: "Get Client ID".localized, target: self, action: #selector(openGetClientIdMenu(_:)))
        let getClientIdBtnWidth = Int(getClientIdBtn.frame.width)
        getClientIdBtn.frame = NSRect(x: Int(self.frame.width) - getClientIdBtnWidth, y: y, width: getClientIdBtnWidth, height: Int(getClientIdBtn.frame.height))
        self.addSubview(getClientIdBtn)
        getClientIdBtn.menu = NSMenu()
        getClientIdBtn.menu?.addItem(withTitle: "Never created Client ID".localized, action: #selector(createClientId(_:)), keyEquivalent: "")
        getClientIdBtn.menu?.addItem(withTitle: "Created Client ID".localized, action: #selector(getClientId(_:)), keyEquivalent: "")
        
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/imgur")
    }
    
    @objc func openGetClientIdMenu(_ sender: NSButton) {
        if let event = NSApplication.shared.currentEvent {
            NSMenu.popUpContextMenu(sender.menu!, with: event, for: sender)
        }
    }
    
    @objc func createClientId(_ sender: NSButton) {
        guard let url = URL(string: "https://blog.svend.cc/upic/tutorials/imgur") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    @objc func getClientId(_ sender: NSButton) {
        guard let url = URL(string: "https://imgur.com/account/settings/apps") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
