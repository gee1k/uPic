//
//  GiteeConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class GiteeConfigView: ConfigView {
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? GiteeHostConfig else {
            return
        }
        
        // MARK: owner
        let ownerLabel = NSTextField(labelWithString: "\(data.displayName(key: "owner")):")
        ownerLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        ownerLabel.alignment = .right
        ownerLabel.lineBreakMode = .byClipping
        
        let ownerField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        ownerField.identifier = NSUserInterfaceItemIdentifier(rawValue: "owner")
        ownerField.usesSingleLineMode = true
        ownerField.lineBreakMode = .byTruncatingTail
        ownerField.delegate = data
        ownerField.stringValue = data.owner ?? ""
        self.addSubview(ownerLabel)
        self.addSubview(ownerField)
        nextKeyViews.append(ownerField)
        
        // MARK: repo
        y = y - gapTop - labelHeight
        
        let repoLabel = NSTextField(labelWithString: "\(data.displayName(key: "repo")):")
        repoLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        repoLabel.alignment = .right
        repoLabel.lineBreakMode = .byClipping
        
        let repoField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        repoField.identifier = NSUserInterfaceItemIdentifier(rawValue: "repo")
        repoField.usesSingleLineMode = true
        repoField.lineBreakMode = .byTruncatingTail
        repoField.delegate = data
        repoField.stringValue = data.repo ?? ""
        repoField.placeholderString = "Just the repo name, not the repo URL".localized
        self.addSubview(repoLabel)
        self.addSubview(repoField)
        nextKeyViews.append(repoField)
        
        // MARK: Branch
        y = y - gapTop - labelHeight
        
        let branchLabel = NSTextField(labelWithString: "\(data.displayName(key: "branch")):")
        branchLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        branchLabel.alignment = .right
        branchLabel.lineBreakMode = .byClipping
        
        let branchField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        branchField.identifier = NSUserInterfaceItemIdentifier(rawValue: "branch")
        branchField.usesSingleLineMode = true
        branchField.lineBreakMode = .byTruncatingTail
        branchField.delegate = data
        branchField.stringValue = data.branch ?? ""
        self.addSubview(branchLabel)
        self.addSubview(branchField)
        nextKeyViews.append(branchField)
        
        // MARK: Token
        y = y - gapTop - labelHeight
        
        let tokenLabel = NSTextField(labelWithString: "\(data.displayName(key: "token")):")
        tokenLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        tokenLabel.alignment = .right
        tokenLabel.lineBreakMode = .byClipping
        
        let tokenField = NSSecureTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        tokenField.identifier = NSUserInterfaceItemIdentifier(rawValue: "token")
        tokenField.usesSingleLineMode = true
        tokenField.lineBreakMode = .byTruncatingTail
        tokenField.delegate = data
        tokenField.stringValue = data.token ?? ""
        self.addSubview(tokenLabel)
        self.addSubview(tokenField)
        nextKeyViews.append(tokenField)
        
        
        // MARK: domain
        y = y - gapTop - labelHeight
        self.createDomainField(data)
        self.domainField?.placeholderString = "Can be empty, there is a default domain".localized
        // MARK: saveKeyPath
        y = y - gapTop - labelHeight
        self.createSaveKeyField(data)
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/gitee")
    }
    
}
