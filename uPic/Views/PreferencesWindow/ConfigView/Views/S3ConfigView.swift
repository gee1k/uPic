//
//  S3ConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2020/8/13.
//  Copyright © 2020 Svend Jin. All rights reserved.
//

import Cocoa

class S3ConfigView: ConfigView {
    
    override var paddingTop: Int {
        return 25
    }
    
    override var gapTop: Int {
        return 6
    }
    
    private var regionLabel: NSTextField!
    private var regionButtonPopUp: NSPopUpButton!
    private var endpointLabel: NSTextField!
    private var endpointField: NSTextField!

    override func createView() {
        super.createView()
        
        guard let data = self.data as? S3HostConfig else {
            return
        }
        
        //Customize
        let customizeLabel = NSTextField(labelWithString: "\(data.displayName(key: "customize")):")
        customizeLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        customizeLabel.alignment = .right
        customizeLabel.lineBreakMode = .byClipping
        
        
        let customizeBtn = NSButton(frame: NSRect(x: textFieldX, y: y, width: 50, height: labelHeight))
        customizeBtn.title = ""
        customizeBtn.target = self
        customizeBtn.action = #selector(customizeChanged(_:))
        customizeBtn.identifier = NSUserInterfaceItemIdentifier(rawValue: "customize")
        customizeBtn.setButtonType(.switch)
        customizeBtn.allowsMixedState = false
        customizeBtn.state = data.customize ? .on : .off
        self.addSubview(customizeLabel)
        self.addSubview(customizeBtn)
        nextKeyViews.append(customizeBtn)
        
        // MARK: Region
        y = y - gapTop - labelHeight
        regionLabel = NSTextField(labelWithString: "\(data.displayName(key: "region")):")
        regionLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        regionLabel.alignment = .right
        regionLabel.lineBreakMode = .byClipping
        
        regionButtonPopUp = NSPopUpButton(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        regionButtonPopUp.target = self
        regionButtonPopUp.action = #selector(regionChange(_:))
        regionButtonPopUp.identifier = NSUserInterfaceItemIdentifier(rawValue: "region")
        
        var selectRegion: NSMenuItem?
        
        let sortedKeys = Array(S3Region.allRegion.keys).sorted()
        
        for key in sortedKeys {
            let title = S3Region.name(key)
            let endPoint = S3Region.endPoint(key)
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
            if data.region == nil || data.region!.isEmpty {
                self.regionChange(regionButtonPopUp)
            }
        }
        
        self.addSubview(regionLabel)
        self.addSubview(regionButtonPopUp)
        nextKeyViews.append(regionButtonPopUp)
        
        
        // MARK: Endpoint
//        y = y - gapTop - labelHeight
        endpointLabel = NSTextField(labelWithString: "\(data.displayName(key: "endpoint")):")
        endpointLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        endpointLabel.alignment = .right
        endpointLabel.lineBreakMode = .byClipping

        endpointField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        endpointField.identifier = NSUserInterfaceItemIdentifier(rawValue: "endpoint")
        endpointField.usesSingleLineMode = true
        endpointField.lineBreakMode = .byTruncatingTail
        endpointField.delegate = data
        endpointField.stringValue = data.endpoint ?? ""
        
        self.addSubview(endpointLabel)
        self.addSubview(endpointField)
        nextKeyViews.append(endpointField)
        
        
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
        bucketField.stringValue = data.bucket
        self.addSubview(bucketLabel)
        self.addSubview(bucketField)
        nextKeyViews.append(bucketField)
        
        // MARK: ACL Control (public-read, private, public-read-write)
        y = y - gapTop - labelHeight - 5

        let aclLabel = NSTextField(labelWithString:"ACL:")
        aclLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight+2)
        aclLabel.alignment = .right
        aclLabel.lineBreakMode = .byClipping

        let aclPopUp = NSPopUpButton(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight+2))
        aclPopUp.target = self
        aclPopUp.action = #selector(aclChange(_:))
        aclPopUp.identifier = NSUserInterfaceItemIdentifier(rawValue: "acl")

        var selectAcl: NSMenuItem?
        for acl in S3ObjectCannedACL.allCases {
            let menuItem = NSMenuItem(title: acl.description, action: nil, keyEquivalent: "")
            menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: acl.rawValue)
            aclPopUp.menu?.addItem(menuItem)

            if data.acl == acl.rawValue {
                selectAcl = menuItem
            }
        }
        
        if selectAcl != nil {
            aclPopUp.select(selectAcl)
        }

        self.addSubview(aclLabel)
        self.addSubview(aclPopUp)
        nextKeyViews.append(aclPopUp)


        // MARK: AccessKey
        y = y - gapTop - labelHeight

        let accessKeyLabel = NSTextField(labelWithString: "\(data.displayName(key: "accessKey")):")
        accessKeyLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        accessKeyLabel.alignment = .right
        accessKeyLabel.lineBreakMode = .byClipping

        let accessKeyField = NSSecureTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        accessKeyField.identifier = NSUserInterfaceItemIdentifier(rawValue: "accessKey")
        accessKeyField.usesSingleLineMode = true
        accessKeyField.lineBreakMode = .byTruncatingTail
        accessKeyField.delegate = data
        accessKeyField.stringValue = data.accessKey
        self.addSubview(accessKeyLabel)
        self.addSubview(accessKeyField)
        self.addRevealToggle(for: accessKeyField)
        nextKeyViews.append(accessKeyField)


        // MARK: secretKey
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
        secretKeyField.stringValue = data.secretKey
        self.addSubview(secretKeyLabel)
        self.addSubview(secretKeyField)
        self.addRevealToggle(for: secretKeyField)
        nextKeyViews.append(secretKeyField)


        // MARK: domain
        y = y - gapTop - labelHeight
        self.createDomainField(data)
        
        // MARK: saveKeyPath
        y = y - gapTop - labelHeight
        self.createSaveKeyField(data)
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/amazon_s3")
        
        changeCustomizeModel(data.customize)
    }
    
    @objc func aclChange(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            print("Changing acl to: \(identifier)") // Add this line
            self.data?.setValue(identifier, forKey: "acl")
        }
    }
        
    @objc func regionChange(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            self.data?.setValue(identifier, forKey: "region")
        }
    }
    
    @objc func customizeChanged(_ sender: NSButton) {
        let customize = sender.state == .on
        self.data?.setValue(customize, forKey: "customize")
        
        changeCustomizeModel(customize)
    }
    
    func changeCustomizeModel(_ customize: Bool) {
        regionLabel.isHidden = customize
        regionButtonPopUp.isHidden = customize
        
        endpointLabel.isHidden = !customize
        endpointField.isHidden = !customize
        
        if (customize) {
            self.data?.setValue(nil, forKey: "region")
        }
        
        if (!customize && !endpointField.stringValue.isEmpty) {
            endpointField.stringValue = ""
            self.data?.setValue(nil, forKey: "endpoint")
        }
    }
}
