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
        
        guard let data = self.data as? GiteeHostConfig else {
            return
        }
        
        let paddingTop = 50, paddingLeft = 6, gapTop = 10, gapLeft = 5, labelWidth = 75, labelHeight = 20,
        viewWidth = Int(self.frame.width), viewHeight = Int(self.frame.height),
        textFieldX = labelWidth + paddingLeft + gapLeft, textFieldWidth = viewWidth - paddingLeft - textFieldX
        
        var y = viewHeight - paddingTop
      
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
        
        let tokenField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
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
        helpBtn.toolTip = "https://blog.svend.cc/upic/tutorials/gitee"
        self.addSubview(helpBtn)
    }
    
}
