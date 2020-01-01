//
//  WeiboConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class WeiboConfigView: ConfigView {
    
    override var paddingTop: Int {
        return 50
    }
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? WeiboHostConfig else {
            return
        }
        
        // MARK: cookie mode
        
        let cookieModeLabel = NSTextField(labelWithString: "\(data.displayName(key: "cookieMode")):")
        cookieModeLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        cookieModeLabel.alignment = .right
        cookieModeLabel.lineBreakMode = .byClipping
        
        
        let cookieModeBtn = NSButton(frame: NSRect(x: textFieldX, y: y, width: 50, height: labelHeight))
        cookieModeBtn.title = ""
        cookieModeBtn.target = self
        cookieModeBtn.action = #selector(cookieModeChanged(_:))
        cookieModeBtn.identifier = NSUserInterfaceItemIdentifier(rawValue: "cookieMode")
        cookieModeBtn.setButtonType(.switch)
        cookieModeBtn.allowsMixedState = false
        cookieModeBtn.state = NSControl.StateValue(rawValue: Int(data.cookieMode) ?? 0)
        self.addSubview(cookieModeLabel)
        self.addSubview(cookieModeBtn)
        nextKeyViews.append(cookieModeBtn)
      
        // MARK: Username
        
        y = y - gapTop - labelHeight
        let usernameLabel = NSTextField(labelWithString: "\(data.displayName(key: "username")):")
        usernameLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        usernameLabel.alignment = .right
        usernameLabel.lineBreakMode = .byClipping
        
        let usernameField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        usernameField.identifier = NSUserInterfaceItemIdentifier(rawValue: "username")
        usernameField.usesSingleLineMode = true
        usernameField.lineBreakMode = .byTruncatingTail
        usernameField.delegate = data
        usernameField.stringValue = data.username ?? ""
        self.addSubview(usernameLabel)
        self.addSubview(usernameField)
        nextKeyViews.append(usernameField)
        
        // MARK: password
        y = y - gapTop - labelHeight
        
        let passwordLabel = NSTextField(labelWithString: "\(data.displayName(key: "password")):")
        passwordLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        passwordLabel.alignment = .right
        passwordLabel.lineBreakMode = .byClipping
        
        let passwordField = NSSecureTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        passwordField.identifier = NSUserInterfaceItemIdentifier(rawValue: "password")
        passwordField.usesSingleLineMode = true
        passwordField.lineBreakMode = .byTruncatingTail
        passwordField.delegate = data
        passwordField.stringValue = data.password ?? ""
        self.addSubview(passwordLabel)
        self.addSubview(passwordField)
        nextKeyViews.append(passwordField)
        
        // MARK: cookie
        y = y - gapTop - labelHeight
        
        let cookieLabel = NSTextField(labelWithString: "\(data.displayName(key: "cookie")):")
        cookieLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        cookieLabel.alignment = .right
        cookieLabel.lineBreakMode = .byClipping
        
        let cookieField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        cookieField.identifier = NSUserInterfaceItemIdentifier(rawValue: "cookie")
        cookieField.usesSingleLineMode = true
        cookieField.lineBreakMode = .byTruncatingTail
        cookieField.delegate = data
        cookieField.stringValue = data.cookie ?? ""
        self.addSubview(cookieLabel)
        self.addSubview(cookieField)
        nextKeyViews.append(cookieField)
        
        
        // MARK: Quality
        y = y - gapTop - labelHeight
        let qualityLabel = NSTextField(labelWithString: "\(data.displayName(key: "quality")):")
        qualityLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        qualityLabel.alignment = .right
        qualityLabel.lineBreakMode = .byClipping
        
        let qualityButtonPopUp = NSPopUpButton(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        qualityButtonPopUp.target = self
        qualityButtonPopUp.action = #selector(qualityChanged(_:))
        qualityButtonPopUp.identifier = NSUserInterfaceItemIdentifier(rawValue: "quality")
        
        var selectquality: NSMenuItem?
        for quality in WeiboqQuality.allCases {
            let menuItem = NSMenuItem(title: quality.name, action: nil, keyEquivalent: "")
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: quality.rawValue)
            qualityButtonPopUp.menu?.addItem(menuItem)
            if data.quality == quality.rawValue {
                selectquality = menuItem
            }
        }
        if selectquality != nil {
            qualityButtonPopUp.select(selectquality)
        }
        
        self.addSubview(qualityLabel)
        self.addSubview(qualityButtonPopUp)
        nextKeyViews.append(qualityButtonPopUp)
       
        // MARK: Domain
        
        y = y - gapTop - labelHeight
        let domainLabel = NSTextField(labelWithString: "\(data.displayName(key: "domain")):")
        domainLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        domainLabel.alignment = .right
        domainLabel.lineBreakMode = .byClipping
        
        let domainField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        domainField.identifier = NSUserInterfaceItemIdentifier(rawValue: "domain")
        domainField.usesSingleLineMode = true
        domainField.lineBreakMode = .byTruncatingTail
        domainField.delegate = data
        domainField.stringValue = data.domain ?? ""
        self.addSubview(domainLabel)
        self.addSubview(domainField)
        nextKeyViews.append(domainField)
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/weibo")
    }
    
    @objc func cookieModeChanged(_ sender: NSButton) {
        self.data?.setValue(String(sender.state.rawValue), forKey: "cookieMode")
    }
    
    
    @objc func qualityChanged(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            self.data?.setValue(identifier, forKey: "quality")
        }
    }
    
}
