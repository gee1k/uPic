//
//  TencentConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class TencentConfigView: ConfigView {
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? TencentHostConfig else {
            return
        }
        
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
        
        let sortedKeys = Array(TencentRegion.allRegion.keys).sorted()
        
        for key in sortedKeys {
            let title = TencentRegion.name(key)
            let endPoint = TencentRegion.endPoint(key)
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: key)
            regionButtonPopUp.menu?.addItem(menuItem)
            if endPoint.isEmpty {
                menuItem.isEnabled = false
            }
            
            if data.region == key {
                selectRegion = menuItem
            }
        }
        
        selectRegion = selectRegion ?? regionButtonPopUp.menu?.items.first
        if selectRegion != nil {
            regionButtonPopUp.select(selectRegion)
            // 初次设置，手动处罚一下事件，将数据写入data
            if (data.region == nil || data.region!.isEmpty) {
                self.regionChange(regionButtonPopUp)
            }
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
        
        // MARK: SecretId
        y = y - gapTop - labelHeight
        
        let secretIdLabel = NSTextField(labelWithString: "\(data.displayName(key: "secretId")):")
        secretIdLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        secretIdLabel.alignment = .right
        secretIdLabel.lineBreakMode = .byClipping
        
        let secretIdField = NSSecureTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        secretIdField.identifier = NSUserInterfaceItemIdentifier(rawValue: "secretId")
        secretIdField.usesSingleLineMode = true
        secretIdField.lineBreakMode = .byTruncatingTail
        secretIdField.delegate = data
        secretIdField.stringValue = data.secretId ?? ""
        self.addSubview(secretIdLabel)
        self.addSubview(secretIdField)
        nextKeyViews.append(secretIdField)
        
        
        // MARK: Password
        y = y - gapTop - labelHeight
        
        let secretKeyLabel = NSTextField(labelWithString: "\(data.displayName(key: "secretKey")):")
        secretKeyLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        secretKeyLabel.alignment = .right
        secretKeyLabel.lineBreakMode = .byClipping
        
        let secretKeyField = NSSecureTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
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
        self.createDomainField(data)
        // MARK: saveKeyPath
        y = y - gapTop - labelHeight
        self.createSaveKeyField(data)
        
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/tencent_cos")
    }
    
    
    @objc func regionChange(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            data?.setValue(identifier, forKey: "region")
        }
    }
}

