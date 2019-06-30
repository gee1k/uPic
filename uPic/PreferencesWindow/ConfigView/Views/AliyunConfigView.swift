//
//  AliyunConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class AliyunConfigView: ConfigView {

    override func createView() {
        
        guard let data = self.data as? AliyunHostConfig else {
            return
        }
        
        let paddingTop = 50, paddingLeft = 6, gapTop = 10, gapLeft = 5, labelWidth = 75, labelHeight = 20,
                viewWidth = Int(self.frame.width), viewHeight = Int(self.frame.height),
                textFieldX = labelWidth + paddingLeft + gapLeft, textFieldWidth = viewWidth - paddingLeft - textFieldX

        var y = viewHeight - paddingTop
        // MARK: Region
        let regionLabel = NSTextField(labelWithString: "\(data.displayName(key: "region")):")
        regionLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        regionLabel.alignment = .right
        regionLabel.lineBreakMode = .byClipping
        
        let regionButtonPopUp = NSPopUpButton(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        regionButtonPopUp.target = self
        regionButtonPopUp.action = #selector(regionChange(_:))
        regionButtonPopUp.identifier = NSUserInterfaceItemIdentifier(rawValue: "region")
        
        var selectRegion: NSMenuItem?
        for region in AliyunRegion.allCases {
            let menuItem = NSMenuItem(title: region.name, action: nil, keyEquivalent: "")
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: region.rawValue)
            regionButtonPopUp.menu?.addItem(menuItem)
            if region.endPoint.isEmpty {
                menuItem.isEnabled = false
            }
            
            if data.region == region.rawValue {
                selectRegion = menuItem
            }
        }
        if selectRegion != nil {
            regionButtonPopUp.select(selectRegion)
        }
        
        self.addSubview(regionLabel)
        self.addSubview(regionButtonPopUp)
        nextKeyViews.append(regionButtonPopUp)
        
        
        // MARK: Bucket
        y = y - gapTop - labelHeight
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

        // MARK: AccessKey
        y = y - gapTop - labelHeight

        let accessKeyLabel = NSTextField(labelWithString: "\(data.displayName(key: "accessKey")):")
        accessKeyLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        accessKeyLabel.alignment = .right
        accessKeyLabel.lineBreakMode = .byClipping

        let accessKeyField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        accessKeyField.identifier = NSUserInterfaceItemIdentifier(rawValue: "accessKey")
        accessKeyField.usesSingleLineMode = true
        accessKeyField.lineBreakMode = .byTruncatingTail
        accessKeyField.delegate = data
        accessKeyField.stringValue = data.accessKey ?? ""
        self.addSubview(accessKeyLabel)
        self.addSubview(accessKeyField)
        nextKeyViews.append(accessKeyField)


        // MARK: Password
        y = y - gapTop - labelHeight

        let secretKeyLabel = NSTextField(labelWithString: "\(data.displayName(key: "secretKey")):")
        secretKeyLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        secretKeyLabel.alignment = .right
        secretKeyLabel.lineBreakMode = .byClipping

        let secretKeyField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        secretKeyField.identifier = NSUserInterfaceItemIdentifier(rawValue: "secretKey")
        secretKeyField.usesSingleLineMode = true
        secretKeyField.lineBreakMode = .byTruncatingTail
        secretKeyField.delegate = data
        secretKeyField.stringValue = data.secretKey ?? ""
        self.addSubview(secretKeyLabel)
        self.addSubview(secretKeyField)
        nextKeyViews.append(secretKeyField)


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
        helpBtn.toolTip = "https://blog.svend.cc/upic/tutorials/aliyun_oss"
        self.addSubview(helpBtn)
    }

    
    @objc func regionChange(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            self.data?.setValue(identifier, forKey: "region")
        }
    }
}
