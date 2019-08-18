//
//  WeiboConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class WeiboConfigView: ConfigView {
    
    override var settings: Bool {
        return false
    }
    
    
    override func createView() {
        
        guard let data = self.data as? WeiboHostConfig else {
            return
        }
        
        let paddingTop = 50, paddingLeft = 6, gapTop = 10, gapLeft = 5, labelWidth = 90, labelHeight = 20,
        viewWidth = Int(self.frame.width), viewHeight = Int(self.frame.height),
        textFieldX = labelWidth + paddingLeft + gapLeft, textFieldWidth = viewWidth - paddingLeft - textFieldX
        
        var y = viewHeight - paddingTop
        
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
        
        let passwordField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
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
       
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        let helpBtnSize = 21
        let helpBtn = NSButton(title: "", target: self, action: #selector(openTutorial(_:)))
        helpBtn.frame = NSRect(x: viewWidth - helpBtnSize * 3 / 2, y: y, width: helpBtnSize, height: helpBtnSize)
        helpBtn.bezelStyle = .helpButton
        helpBtn.setButtonType(.momentaryPushIn)
        helpBtn.toolTip = "https://blog.svend.cc/upic/tutorials/weibo"
        self.addSubview(helpBtn)
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
