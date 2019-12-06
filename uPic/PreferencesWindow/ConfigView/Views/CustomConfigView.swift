//
//  CustomConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/27.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class CustomConfigView: ConfigView {
    
    var postConfigSheetController: CustomConfigSheetController?;
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        postConfigSheetController = (self.window?.contentViewController?.storyboard!.instantiateController(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomConfigSheetController").rawValue)
            as! CustomConfigSheetController)
        
    }
    
    
    deinit {
        postConfigSheetController?.removeFromParent()
    }

    override func createView() {
        super.createView()
        
        guard let data = self.data as? CustomHostConfig else {
            return
        }
        
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
        let otherFieldsBtnWith = 100
        
        let fieldLabel = NSTextField(labelWithString: "\(data.displayName(key: "field")):")
        fieldLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        fieldLabel.alignment = .right
        fieldLabel.lineBreakMode = .byClipping

        let fieldField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth - otherFieldsBtnWith, height: labelHeight))
        fieldField.identifier = NSUserInterfaceItemIdentifier(rawValue: "field")
        fieldField.usesSingleLineMode = true
        fieldField.lineBreakMode = .byTruncatingTail
        fieldField.delegate = data
        fieldField.stringValue = data.field ?? ""
        
        
        let otherFieldsBtn = NSButton(title: "Other fields".localized, target: self, action: #selector(openCustomConfigSheet(_:)))
        otherFieldsBtn.frame = NSRect(x: textFieldX + Int(fieldField.frame.width) + gapLeft, y: y, width: otherFieldsBtnWith, height: labelHeight)
        otherFieldsBtn.imagePosition = .noImage
        
        self.addSubview(fieldLabel)
        self.addSubview(fieldField)
        self.addSubview(otherFieldsBtn)
        nextKeyViews.append(fieldField)
        nextKeyViews.append(otherFieldsBtn)
        
        
        // MARK: resultPath
        y = y - gapTop - labelHeight
        let resultLabel = NSTextField(labelWithString: "\(data.displayName(key: "resultPath")):")
        resultLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        resultLabel.alignment = .right
        resultLabel.lineBreakMode = .byClipping
        
        let resultField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        resultField.identifier = NSUserInterfaceItemIdentifier(rawValue: "resultPath")
        resultField.usesSingleLineMode = true
        resultField.lineBreakMode = .byTruncatingTail
        resultField.delegate = data
        resultField.stringValue = data.resultPath ?? ""
        resultField.placeholderString = "The path to the URL field in Response JSON".localized
        resultField.toolTip = "The path to the URL field in Response JSON".localized
        self.addSubview(resultLabel)
        self.addSubview(resultField)
        nextKeyViews.append(resultField)
        
        
        // MARK: domain
        y = y - gapTop - labelHeight
        self.createDomainField(data)
        self.domainField?.placeholderString = "(optional),When filled, URL = domain + URL path value".localized
        self.domainField?.toolTip = "(optional),When filled, URL = domain + URL path value".localized
        
        // MARK: saveKeyPath
        y = y - gapTop - labelHeight
        self.createSaveKeyField(data)
        
        
        // MARK: help
        y = y - gapTop - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/custom")
        
    }
    
    @objc func methodChange(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            self.data?.setValue(identifier, forKey: "method")
        }
    }
    
    @objc func openCustomConfigSheet(_ sender: NSButton) {
        guard let data = self.data as? CustomHostConfig else {
            return
        }
        
        if let postConfigSheetController = postConfigSheetController {
            self.window?.contentViewController?.presentAsSheet(postConfigSheetController)
            postConfigSheetController.setData(headerStr: data.headers ?? "", bodyStr: data.bodys ?? "")
            self.addCustomConfigObserver()
        }
    }
    
    func addCustomConfigObserver() {
        PreferencesNotifier.addObserver(observer: self, selector: #selector(saveExtensionsSettings), notification: .saveCustomExtensionSettings)
    }
    
    
    func removeCustomConfigObserver() {
        PreferencesNotifier.removeObserver(observer: self, notification: .saveCustomExtensionSettings)
    }
    
    @objc func saveExtensionsSettings(notification: Notification) {
        self.removeCustomConfigObserver()
        guard let userInfo = notification.userInfo else {
            print("No userInfo found in notification")
            return
        }
        
        let headers = userInfo["headers"] as? String ?? ""
        let bodys = userInfo["bodys"] as? String ??  ""
        
        self.data?.setValue(headers, forKey: "headers")
        self.data?.setValue(bodys, forKey: "bodys")
    }
}
