//
//  CustomConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/27.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class CustomConfigView: NSView {

    var data: CustomHostConfig = CustomHostConfig()

    var domainField: NSTextField!

    var configSheetController: ConfigSheetController!

    override func viewWillDraw() {
        super.viewWillDraw()
        // Do view setup here.

        configSheetController = (self.window?.contentViewController?.storyboard!.instantiateController(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConfigSheetController").rawValue)
                as! ConfigSheetController)

        self.createView()
    }

    init(frame frameRect: NSRect, data: HostConfig?) {
        super.init(frame: frameRect)

        if data != nil {
            self.data = data as! CustomHostConfig
        }

    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if configSheetController != nil {
            configSheetController.removeFromParent()
        }
    }


    func createView() {

        let paddingTop = 30, paddingLeft = 6, gapTop = 10, gapLeft = 5, labelWidth = 75, labelHeight = 20, textAreaHeight = 50,
                viewWidth = Int(self.frame.width), viewHeight = Int(self.frame.height),
                textFieldX = labelWidth + paddingLeft + gapLeft, textFieldWidth = viewWidth - paddingLeft - textFieldX

        var y = viewHeight - paddingTop
        // MARK: url
        let urlLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "url")):")
        urlLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        urlLabel.alignment = .right
        urlLabel.lineBreakMode = .byClipping
        
        let urlField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        urlField.identifier = NSUserInterfaceItemIdentifier(rawValue: "url")
        urlField.delegate = self.data
        urlField.stringValue = self.data.url ?? ""
        self.addSubview(urlLabel)
        self.addSubview(urlField)
        
        // MARK: Method
        y = y - gapTop - labelHeight
        let methodLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "method")):")
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
        
        
        // MARK: field
        y = y - gapTop - labelHeight
        let fieldLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "field")):")
        fieldLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        fieldLabel.alignment = .right
        fieldLabel.lineBreakMode = .byClipping

        let fieldField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        fieldField.identifier = NSUserInterfaceItemIdentifier(rawValue: "field")
        fieldField.delegate = self.data
        fieldField.stringValue = self.data.field ?? ""
        self.addSubview(fieldLabel)
        self.addSubview(fieldField)
        
        // MARK: Extensions
        y = y - gapTop - labelHeight
        let extensionsLabel = NSTextField(labelWithString: "扩展字段:")
        extensionsLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        extensionsLabel.alignment = .right
        extensionsLabel.lineBreakMode = .byClipping
        
        let extensionsField = NSTextField(frame: NSRect(x: textFieldX, y: y + labelHeight - textAreaHeight, width: textFieldWidth, height: textAreaHeight))
        extensionsField.usesSingleLineMode = false
        extensionsField.lineBreakMode = .byWordWrapping
        extensionsField.cell?.wraps = true
        extensionsField.identifier = NSUserInterfaceItemIdentifier(rawValue: "extensions")
        extensionsField.delegate = self.data
        extensionsField.stringValue = self.data.extensions ?? ""
        extensionsField.placeholderString = "eg: key=value&key2=value2"
        self.addSubview(extensionsLabel)
        self.addSubview(extensionsField)
        
        // MARK: Headers
        y = y - gapTop - textAreaHeight
        let headersLabel = NSTextField(labelWithString: "请求头:")
        headersLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        headersLabel.alignment = .right
        headersLabel.lineBreakMode = .byClipping
        
        let headersField = NSTextField(frame: NSRect(x: textFieldX, y: y + labelHeight - textAreaHeight, width: textFieldWidth, height: textAreaHeight))
        headersField.usesSingleLineMode = false
        headersField.lineBreakMode = .byWordWrapping
        headersField.cell?.wraps = true
        headersField.identifier = NSUserInterfaceItemIdentifier(rawValue: "headers")
        headersField.delegate = self.data
        headersField.stringValue = self.data.headers ?? ""
        headersField.placeholderString = "eg: key=value&key2=value2"
        self.addSubview(headersLabel)
        self.addSubview(headersField)


        // MARK: domain
        y = y - gapTop - textAreaHeight
        let settingsBtnWith = 40

        let domainLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "domain")):")
        domainLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        domainLabel.alignment = .right
        domainLabel.lineBreakMode = .byClipping

        let domainField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth - settingsBtnWith, height: labelHeight))
        domainField.identifier = NSUserInterfaceItemIdentifier(rawValue: "domain")
        domainField.delegate = self.data
        domainField.stringValue = self.data.domain ?? ""
        self.domainField = domainField

        let settingsBtn = NSButton(title: "", image: NSImage(named: NSImage.advancedName)!, target: self, action: #selector(openConfigSheet(_:)))
        settingsBtn.frame = NSRect(x: textFieldX + Int(domainField.frame.width) + gapLeft, y: y, width: settingsBtnWith, height: labelHeight)
        settingsBtn.imagePosition = .imageOnly

        self.addSubview(domainLabel)
        self.addSubview(domainField)
        self.addSubview(settingsBtn)
        
        // MARK: help
        y = y - gapTop - labelHeight
        let helpBtnSize = 21
        let helpBtn = NSButton(title: "", target: self, action: #selector(openTutorial))
        helpBtn.frame = NSRect(x: viewWidth - helpBtnSize * 3 / 2, y: y, width: helpBtnSize, height: helpBtnSize)
        helpBtn.bezelStyle = .helpButton
        helpBtn.setButtonType(.momentaryPushIn)
        helpBtn.toolTip = NSLocalizedString("tutorial.tooltip", comment: "tutorial")
        self.addSubview(helpBtn)
    }

    func addObserver() {
        PreferencesNotifier.addObserver(observer: self, selector: #selector(saveHostSettings), notification: PreferencesNotifier.Notification.saveHostSettings)
    }


    func removeObserver() {
        PreferencesNotifier.removeObserver(observer: self, notification: .saveHostSettings)
        PreferencesNotifier.addObserver(observer: self, selector: #selector(saveHostSettings), notification: .saveHostSettings)
    }
    
    @objc func openTutorial() {
        guard let url = URL(string: "https://blog.svend.cc/upic/tutorials/custom") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @objc func openConfigSheet(_ sender: NSButton) {
        let userInfo: [String: Any] = ["domain": self.data.domain ?? "", "saveKey": self.data.saveKey ?? HostSaveKey.dateFilename.rawValue]
        self.window?.contentViewController?.presentAsSheet(configSheetController)
        configSheetController.setData(userInfo: userInfo as [String: AnyObject])
        self.addObserver()

    }

    @objc func saveHostSettings(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print("No userInfo found in notification")
            return
        }

        self.data.domain = userInfo["domain"] as? String ?? ""
        self.data.folder = userInfo["folder"] as? String ?? ""
        self.data.saveKey = userInfo["saveKey"] as? String ?? HostSaveKey.dateFilename.rawValue

        domainField.stringValue = self.data.domain!
    }
    
    
    @objc func methodChange(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            self.data.method = identifier
        }
    }
}
