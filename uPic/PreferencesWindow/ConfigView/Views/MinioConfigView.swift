//
//  MinioConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2020/4/12.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class MinioConfigView: ConfigView {

    override func createView() {
        super.createView()
        
        guard let data = self.data as? MinioHostConfig else {
            return
        }

        let urlLabel = NSTextField(labelWithString: "\(data.displayName(key: "url")):")
        urlLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        urlLabel.alignment = .right
        urlLabel.lineBreakMode = .byClipping

        let urlField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        urlField.identifier = NSUserInterfaceItemIdentifier(rawValue: "url")
        urlField.usesSingleLineMode = true
        urlField.lineBreakMode = .byTruncatingTail
        urlField.delegate = data
        urlField.stringValue = data.url
        urlField.placeholderString = "http://127.0.0.1:9000"
        self.addSubview(urlLabel)
        self.addSubview(urlField)
        nextKeyViews.append(urlField)
        
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
        nextKeyViews.append(secretKeyField)


        // MARK: domain
//        y = y - gapTop - labelHeight
//        self.createDomainField(data)
        
        // MARK: saveKeyPath
        y = y - gapTop - labelHeight
        self.createSaveKeyField(data)
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/amazon_s3")
    }

    
    @objc func regionChange(_ sender: NSPopUpButton) {
        if let menuItem = sender.selectedItem, let identifier = menuItem.identifier?.rawValue {
            self.data?.setValue(identifier, forKey: "region")
        }
    }
}
