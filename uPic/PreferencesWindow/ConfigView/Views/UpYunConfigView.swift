//
//  UpYunConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/19.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class UpYunConfigView: ConfigView {

    override func createView() {
        
        guard let data = self.data as? UpYunHostConfig else {
            return
        }

        let paddingTop = 50, paddingLeft = 10, gapTop = 10, gapLeft = 5, labelWidth = 65, labelHeight = 20,
                viewWidth = Int(self.frame.width), viewHeight = Int(self.frame.height),
                textFieldX = labelWidth + paddingLeft + gapLeft, textFieldWidth = viewWidth - paddingLeft - textFieldX

        var y = viewHeight - paddingTop

        // MARK: Bucket
        let bucketLabel = NSTextField(labelWithString: "\(data.displayName(key: "bucket")):")
        bucketLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        bucketLabel.alignment = .right
        bucketLabel.lineBreakMode = .byClipping

        let bucketField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        bucketField.identifier = NSUserInterfaceItemIdentifier(rawValue: "bucket")
        bucketField.usesSingleLineMode = true
        bucketField.lineBreakMode = .byTruncatingTail
        bucketField.delegate = data
        bucketField.stringValue = data.bucket ?? ""
        self.addSubview(bucketLabel)
        self.addSubview(bucketField)
        nextKeyViews.append(bucketField)

        // MARK: Operator
        y = y - gapTop - labelHeight

        let operatorLabel = NSTextField(labelWithString: "\(data.displayName(key: "operatorName")):")
        operatorLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        operatorLabel.alignment = .right
        operatorLabel.lineBreakMode = .byClipping

        let operatorField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        operatorField.identifier = NSUserInterfaceItemIdentifier(rawValue: "operatorName")
        operatorField.usesSingleLineMode = true
        operatorField.lineBreakMode = .byTruncatingTail
        operatorField.delegate = data
        operatorField.stringValue = data.operatorName ?? ""
        operatorField.placeholderString = NSLocalizedString("host.placeholder.operator", comment: "")
        self.addSubview(operatorLabel)
        self.addSubview(operatorField)
        nextKeyViews.append(operatorField)


        // MARK: Password
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
        passwordField.placeholderString = NSLocalizedString("host.placeholder.operator-password", comment: "")
        self.addSubview(passwordLabel)
        self.addSubview(passwordField)
        nextKeyViews.append(passwordField)


        // MARK: domain
        y = y - gapTop - labelHeight
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
        y = y - gapTop * 2 - labelHeight
        let helpBtnSize = 21
        let helpBtn = NSButton(title: "", target: self, action: #selector(openTutorial(_:)))
        helpBtn.frame = NSRect(x: viewWidth - helpBtnSize * 3 / 2, y: y, width: helpBtnSize, height: helpBtnSize)
        helpBtn.bezelStyle = .helpButton
        helpBtn.setButtonType(.momentaryPushIn)
        helpBtn.toolTip = "https://blog.svend.cc/upic/tutorials/upyun_uss"
        self.addSubview(helpBtn)
        
    }

}
