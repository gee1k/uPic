//
//  SmmsConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class SmmsConfigView: ConfigView {
    
    var tokenLabel: NSTextField!
    var tokenField: NSSecureTextField!
    var tokenBtn: NSButton!
    
    override var paddingTop: Int {
        return 50
    }
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? SmmsHostConfig else {
            return
        }
        
        
        let versionLabel = NSTextField(labelWithString: "\(data.displayName(key: "version")):")
        versionLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        versionLabel.alignment = .right
        versionLabel.lineBreakMode = .byClipping
        
        let versionButtonPopUp = NSPopUpButton(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        versionButtonPopUp.target = self
        versionButtonPopUp.action = #selector(versionChanged(_:))
        versionButtonPopUp.identifier = NSUserInterfaceItemIdentifier(rawValue: "version")
        
        var selectVersion: NSMenuItem?
        for version in SmmsVersion.allCases {
            let menuItem = NSMenuItem(title: version.name, action: nil, keyEquivalent: "")
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: version.rawValue)
            versionButtonPopUp.menu?.addItem(menuItem)
            if data.version == version.rawValue {
                selectVersion = menuItem
            }
        }
        if selectVersion != nil {
            versionButtonPopUp.select(selectVersion)
        }
        self.addSubview(versionLabel)
        self.addSubview(versionButtonPopUp)
        nextKeyViews.append(versionButtonPopUp)
      
        // MARK: Token
        
        y = y - gapTop - labelHeight
        tokenLabel = NSTextField(labelWithString: "\(data.displayName(key: "token")):")
        tokenLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        tokenLabel.alignment = .right
        tokenLabel.lineBreakMode = .byClipping
        tokenLabel.isHidden = true
        
        tokenField = NSSecureTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        tokenField.identifier = NSUserInterfaceItemIdentifier(rawValue: "token")
        tokenField.usesSingleLineMode = true
        tokenField.lineBreakMode = .byTruncatingTail
        tokenField.delegate = data
        tokenField.stringValue = data.token ?? ""
        tokenField.isHidden = true
        self.addSubview(tokenLabel)
        self.addSubview(tokenField)
        nextKeyViews.append(tokenField)
        
        // Get API Token
        
        y = y - gapTop - labelHeight
        tokenBtn = NSButton(title: "Get API Token".localized, target: self, action: #selector(getApiToken(_:)))
        let tokenBtnWidth = Int(tokenBtn.frame.width)
        tokenBtn.frame = NSRect(x: Int(self.frame.width) - tokenBtnWidth, y: y, width: tokenBtnWidth, height: Int(tokenBtn.frame.height))
        tokenBtn.isHidden = true
        self.addSubview(tokenBtn)
        
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/smms")
        

        versionChanged(versionButtonPopUp)
    }
    
    @objc func getApiToken(_ sender: NSButton) {
        guard let url = URL(string: "https://sm.ms/home/apitoken") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    
    @objc func versionChanged(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            
            if self.data?.value(forKey: "version") as? String != identifier {
                self.data?.setValue(identifier, forKey: "version")
            }
            
            let isV2 = identifier == SmmsVersion.v2.rawValue
            tokenLabel.isHidden = !isV2
            tokenField.isHidden = !isV2
            tokenBtn.isHidden = !isV2
        }
    }
    
}
