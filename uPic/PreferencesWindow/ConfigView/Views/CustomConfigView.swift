//
//  CustomConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/27.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class CustomConfigView: ConfigView {

    override func createView() {
        
        guard let data = self.data as? CustomHostConfig else {
            return
        }
        
        let paddingTop = 30, paddingLeft = 6, gapTop = 10, gapLeft = 5, labelWidth = 75, labelHeight = 20, textAreaHeight = 50,
                viewWidth = Int(self.frame.width), viewHeight = Int(self.frame.height),
                textFieldX = labelWidth + paddingLeft + gapLeft, textFieldWidth = viewWidth - paddingLeft - textFieldX

        var y = viewHeight - paddingTop
        // MARK: url
        let urlLabel = NSTextField(labelWithString: "\(data.displayName(key: "url")):")
        urlLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        urlLabel.alignment = .right
        urlLabel.lineBreakMode = .byClipping
        
        let urlField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        urlField.identifier = NSUserInterfaceItemIdentifier(rawValue: "url")
        urlField.usesSingleLineMode = true
        urlField.lineBreakMode = .byTruncatingTail
        urlField.delegate = data
        urlField.stringValue = data.url ?? ""
        self.addSubview(urlLabel)
        self.addSubview(urlField)
        nextKeyViews.append(urlField)
        
        // MARK: Method
        y = y - gapTop - labelHeight
        let methodLabel = NSTextField(labelWithString: "\(data.displayName(key: "method")):")
        methodLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        methodLabel.alignment = .right
        methodLabel.lineBreakMode = .byClipping
        
        let methodButtonPopUp = NSPopUpButton(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        methodButtonPopUp.target = self
        methodButtonPopUp.action = #selector(methodChange(_:))
        methodButtonPopUp.identifier = NSUserInterfaceItemIdentifier(rawValue: "method")
        
        var selectMethod: NSMenuItem?
        for method in RequestMethods.allCases {
            let menuItem = NSMenuItem(title: method.rawValue, action: nil, keyEquivalent: "")
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: method.rawValue)
            methodButtonPopUp.menu?.addItem(menuItem)
            
            if data.method == method.rawValue {
                selectMethod = menuItem
            }
        }
        if selectMethod != nil {
            methodButtonPopUp.select(selectMethod)
        }
        
        self.addSubview(methodLabel)
        self.addSubview(methodButtonPopUp)
        nextKeyViews.append(methodButtonPopUp)
        
        
        // MARK: field
        y = y - gapTop - labelHeight
        let fieldLabel = NSTextField(labelWithString: "\(data.displayName(key: "field")):")
        fieldLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        fieldLabel.alignment = .right
        fieldLabel.lineBreakMode = .byClipping

        let fieldField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        fieldField.identifier = NSUserInterfaceItemIdentifier(rawValue: "field")
        fieldField.usesSingleLineMode = true
        fieldField.lineBreakMode = .byTruncatingTail
        fieldField.delegate = data
        fieldField.stringValue = data.field ?? ""
        self.addSubview(fieldLabel)
        self.addSubview(fieldField)
        nextKeyViews.append(fieldField)
        
        // MARK: Extensions
        y = y - gapTop - labelHeight
        let extensionsLabel = NSTextField(labelWithString: "\(data.displayName(key: "extensions")):")
        extensionsLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        extensionsLabel.alignment = .right
        extensionsLabel.lineBreakMode = .byClipping
        
        let extensionsField = NSTextField(frame: NSRect(x: textFieldX, y: y + labelHeight - textAreaHeight, width: textFieldWidth, height: textAreaHeight))
        extensionsField.usesSingleLineMode = false
        extensionsField.lineBreakMode = .byWordWrapping
        extensionsField.cell?.wraps = true
        extensionsField.identifier = NSUserInterfaceItemIdentifier(rawValue: "extensions")
        extensionsField.delegate = data
        extensionsField.stringValue = data.extensions ?? ""
        extensionsField.placeholderString = "eg: key=value&key2=value2"
        self.addSubview(extensionsLabel)
        self.addSubview(extensionsField)
        nextKeyViews.append(extensionsField)
        
        // MARK: Headers
        y = y - gapTop - textAreaHeight
        let headersLabel = NSTextField(labelWithString: "\(data.displayName(key: "headers")):")
        headersLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        headersLabel.alignment = .right
        headersLabel.lineBreakMode = .byClipping
        
        let headersField = NSTextField(frame: NSRect(x: textFieldX, y: y + labelHeight - textAreaHeight, width: textFieldWidth, height: textAreaHeight))
        headersField.usesSingleLineMode = false
        headersField.lineBreakMode = .byWordWrapping
        headersField.cell?.wraps = true
        headersField.identifier = NSUserInterfaceItemIdentifier(rawValue: "headers")
        headersField.delegate = data
        headersField.stringValue = data.headers ?? ""
        headersField.placeholderString = "eg: key=value&key2=value2"
        self.addSubview(headersLabel)
        self.addSubview(headersField)
        nextKeyViews.append(headersField)

        // MARK: domain
        y = y - gapTop - textAreaHeight
        let settingsBtnWith = 40

        let domainLabel = NSTextField(labelWithString: "\(data.displayName(key: "domain")):")
        domainLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        domainLabel.alignment = .right
        domainLabel.lineBreakMode = .byClipping

        let domainField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth - settingsBtnWith, height: labelHeight))
        domainField.identifier = NSUserInterfaceItemIdentifier(rawValue: "domain")
        domainField.usesSingleLineMode = true
        domainField.lineBreakMode = .byTruncatingTail
        domainField.delegate = data
        domainField.stringValue = data.domain ?? ""
        domainField.placeholderString = NSLocalizedString("host.placeholder.domain", comment: "")
        self.domainField = domainField

        let settingsBtn = NSButton(title: "", image: NSImage(named: NSImage.advancedName)!, target: self, action: #selector(openConfigSheet(_:)))
        settingsBtn.frame = NSRect(x: textFieldX + Int(domainField.frame.width) + gapLeft, y: y, width: settingsBtnWith, height: labelHeight)
        settingsBtn.imagePosition = .imageOnly

        self.addSubview(domainLabel)
        self.addSubview(domainField)
        self.addSubview(settingsBtn)
        nextKeyViews.append(domainField)
        nextKeyViews.append(settingsBtn)
        
        // MARK: help
        y = y - gapTop - labelHeight
        let helpBtnSize = 21
        let helpBtn = NSButton(title: "", target: self, action: #selector(openTutorial(_:)))
        helpBtn.frame = NSRect(x: viewWidth - helpBtnSize * 3 / 2, y: y, width: helpBtnSize, height: helpBtnSize)
        helpBtn.bezelStyle = .helpButton
        helpBtn.setButtonType(.momentaryPushIn)
        helpBtn.toolTip = "https://blog.svend.cc/upic/tutorials/custom"
        self.addSubview(helpBtn)
        
    }
    
    @objc func methodChange(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            self.data?.setValue(identifier, forKey: "method")
        }
    }
}
