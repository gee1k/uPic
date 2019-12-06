//
//  UpYunConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/19.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class UpYunConfigView: ConfigView {
    
    override var paddingTop: Int {
        return 50
    }
    
    override var labelWidth: Int {
        return 65
    }
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? UpYunHostConfig else {
            return
        }
        
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
        operatorField.placeholderString = "Operator name".localized
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
        passwordField.placeholderString = "Operator password".localized
        self.addSubview(passwordLabel)
        self.addSubview(passwordField)
        nextKeyViews.append(passwordField)
        
        // MARK: domain
        y = y - gapTop - labelHeight
        self.createDomainField(data)
        // MARK: saveKeyPath
        y = y - gapTop - labelHeight
        self.createSaveKeyField(data)
        
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/upyun_uss")
        
    }

}
