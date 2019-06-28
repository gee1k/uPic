//
//  UpYunConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/19.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class UpYunConfigView: NSView {

    var data: UpYunHostConfig = UpYunHostConfig()

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
            self.data = data as! UpYunHostConfig
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
        var nextKeyViews = [NSView]()

        let paddingTop = 50, paddingLeft = 10, gapTop = 10, gapLeft = 5, labelWidth = 60, labelHeight = 20,
                viewWidth = Int(self.frame.width), viewHeight = Int(self.frame.height),
                textFieldX = labelWidth + paddingLeft + gapLeft, textFieldWidth = viewWidth - paddingLeft - textFieldX

        var y = viewHeight - paddingTop

        // MARK: Bucket
        let bucketLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "bucket")):")
        bucketLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        bucketLabel.alignment = .right
        bucketLabel.lineBreakMode = .byClipping

        let bucketField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        bucketField.identifier = NSUserInterfaceItemIdentifier(rawValue: "bucket")
        bucketField.usesSingleLineMode = true
        bucketField.lineBreakMode = .byTruncatingTail
        bucketField.delegate = self.data
        bucketField.stringValue = self.data.bucket ?? ""
        self.addSubview(bucketLabel)
        self.addSubview(bucketField)
        nextKeyViews.append(bucketField)

        // MARK: Operator
        y = y - gapTop - labelHeight

        let operatorLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "operatorName")):")
        operatorLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        operatorLabel.alignment = .right
        operatorLabel.lineBreakMode = .byClipping

        let operatorField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        operatorField.identifier = NSUserInterfaceItemIdentifier(rawValue: "operatorName")
        operatorField.usesSingleLineMode = true
        operatorField.lineBreakMode = .byTruncatingTail
        operatorField.delegate = self.data
        operatorField.stringValue = self.data.operatorName ?? ""
        self.addSubview(operatorLabel)
        self.addSubview(operatorField)
        nextKeyViews.append(operatorField)


        // MARK: Password
        y = y - gapTop - labelHeight

        let passwordLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "password")):")
        passwordLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        passwordLabel.alignment = .right
        passwordLabel.lineBreakMode = .byClipping

        let passwordField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        passwordField.identifier = NSUserInterfaceItemIdentifier(rawValue: "password")
        passwordField.usesSingleLineMode = true
        passwordField.lineBreakMode = .byTruncatingTail
        passwordField.delegate = self.data
        passwordField.stringValue = self.data.password ?? ""
        self.addSubview(passwordLabel)
        self.addSubview(passwordField)
        nextKeyViews.append(passwordField)


        // MARK: domain
        y = y - gapTop - labelHeight
        let settingsBtnWith = 40

        let domainLabel = NSTextField(labelWithString: "\(self.data.displayName(key: "domain")):")
        domainLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        domainLabel.alignment = .right
        domainLabel.lineBreakMode = .byClipping

        let domainField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth - settingsBtnWith, height: labelHeight))
        domainField.identifier = NSUserInterfaceItemIdentifier(rawValue: "domain")
        domainField.usesSingleLineMode = true
        domainField.lineBreakMode = .byTruncatingTail
        domainField.delegate = self.data
        domainField.stringValue = self.data.domain ?? ""
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
        y = y - gapTop * 2 - labelHeight
        let helpBtnSize = 21
        let helpBtn = NSButton(title: "", target: self, action: #selector(openTutorial))
        helpBtn.frame = NSRect(x: viewWidth - helpBtnSize * 3 / 2, y: y, width: helpBtnSize, height: helpBtnSize)
        helpBtn.bezelStyle = .helpButton
        helpBtn.setButtonType(.momentaryPushIn)
        helpBtn.toolTip = NSLocalizedString("tutorial.tooltip", comment: "tutorial")
        self.addSubview(helpBtn)
        
        
        // set nextKeyView
        setNextKeyViews(nextKeyViews: nextKeyViews)
    }

    func addObserver() {
        PreferencesNotifier.addObserver(observer: self, selector: #selector(saveHostSettings), notification: PreferencesNotifier.Notification.saveHostSettings)
    }


    func removeObserver() {
        PreferencesNotifier.removeObserver(observer: self, notification: .saveHostSettings)
        PreferencesNotifier.addObserver(observer: self, selector: #selector(saveHostSettings), notification: .saveHostSettings)
    }
    
    
    @objc func openTutorial() {
        guard let url = URL(string: "https://blog.svend.cc/upic/tutorials/upyun_uss") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @objc func openConfigSheet(_ sender: NSButton) {
        let userInfo: [String: Any] = ["domain": self.data.domain ?? "", "folder": self.data.folder ?? "", "saveKey": self.data.saveKey ?? HostSaveKey.dateFilename.rawValue]
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
}
