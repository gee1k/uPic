//
//  LskyProConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2020/2/28.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class LskyProConfigView: ConfigView {
    
    override var paddingTop: Int {
        return 50
    }
    
    private var emailLabel: NSTextField!
    private var emailField: NSTextField!
    private var passwordLabel: NSTextField!
    private var passwordField: NSTextField!
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? LskyProHostConfig else {
            return
        }
        
        let domainLabel = NSTextField(labelWithString: "\(data.displayName(key: "domain")):")
        domainLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        domainLabel.alignment = .right
        domainLabel.lineBreakMode = .byClipping
        
        let domainField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        domainField.identifier = NSUserInterfaceItemIdentifier(rawValue: "domain")
        domainField.usesSingleLineMode = true
        domainField.lineBreakMode = .byTruncatingTail
        domainField.delegate = data
        domainField.stringValue = data.domain
        self.addSubview(domainLabel)
        self.addSubview(domainField)
        nextKeyViews.append(domainField)
        
        
        y = y - gapTop - labelHeight
        let isAnonymousLabel = NSTextField(labelWithString: "\(data.displayName(key: "isAnonymous")):")
        isAnonymousLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        isAnonymousLabel.alignment = .right
        isAnonymousLabel.lineBreakMode = .byClipping
        
        
        let isAnonymousBtn = NSButton(frame: NSRect(x: textFieldX, y: y, width: 50, height: labelHeight))
        isAnonymousBtn.title = ""
        isAnonymousBtn.target = self
        isAnonymousBtn.action = #selector(isAnonymousChanged(_:))
        isAnonymousBtn.identifier = NSUserInterfaceItemIdentifier(rawValue: "isAnonymous")
        isAnonymousBtn.setButtonType(.switch)
        isAnonymousBtn.allowsMixedState = false
        isAnonymousBtn.state = data.isAnonymous ? .on : .off
        self.addSubview(isAnonymousLabel)
        self.addSubview(isAnonymousBtn)
        nextKeyViews.append(isAnonymousBtn)
      
        // MARK: Email
        
        y = y - gapTop - labelHeight
        emailLabel = NSTextField(labelWithString: "\(data.displayName(key: "email")):")
        emailLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        emailLabel.alignment = .right
        emailLabel.lineBreakMode = .byClipping
        
        emailField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        emailField.identifier = NSUserInterfaceItemIdentifier(rawValue: "email")
        emailField.usesSingleLineMode = true
        emailField.lineBreakMode = .byTruncatingTail
        emailField.delegate = data
        emailField.stringValue = data.email
        self.addSubview(emailLabel)
        self.addSubview(emailField)
        nextKeyViews.append(emailField)
        
        // MARK: password
        y = y - gapTop - labelHeight
        
        passwordLabel = NSTextField(labelWithString: "\(data.displayName(key: "password")):")
        passwordLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        passwordLabel.alignment = .right
        passwordLabel.lineBreakMode = .byClipping
        
        passwordField = NSSecureTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        passwordField.identifier = NSUserInterfaceItemIdentifier(rawValue: "password")
        passwordField.usesSingleLineMode = true
        passwordField.lineBreakMode = .byTruncatingTail
        passwordField.delegate = data
        passwordField.stringValue = data.password 
        self.addSubview(passwordLabel)
        self.addSubview(passwordField)
        nextKeyViews.append(passwordField)
        
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://www.lsky.pro/")
        
        refreshView(data.isAnonymous)
    }
    
    @objc func isAnonymousChanged(_ sender: NSButton) {
        let isAnonymous = sender.state == .on
        
        self.data?.setValue(isAnonymous, forKey: "isAnonymous")
        
        refreshView(isAnonymous)
    }
    
    func refreshView(_ isAnonymous: Bool) {
        emailLabel.isHidden = isAnonymous
        emailField.isHidden = isAnonymous
        passwordLabel.isHidden = isAnonymous
        passwordField.isHidden = isAnonymous
    }
    
}
