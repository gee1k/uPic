//
//  CodingConfigView.swift
//  uPic
//
//  Created by 杨宇 on 2022/4/14.
//  Copyright © 2022 Svend Jin. All rights reserved.
//

import Cocoa

class CodingConfigView: ConfigView {
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? CodingHostConfig else {
            return
        }
        
        // MARK: team
        let teamLabel = NSTextField(labelWithString: "\(data.displayName(key: "team")):")
        teamLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        teamLabel.alignment = .right
        teamLabel.lineBreakMode = .byClipping
        
        let teamField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        teamField.identifier = NSUserInterfaceItemIdentifier(rawValue: "team")
        teamField.usesSingleLineMode = true
        teamField.lineBreakMode = .byTruncatingTail
        teamField.delegate = data
        teamField.stringValue = data.team
        teamField.placeholderString = "CODING team golbal key(<xxx>.coding.net)".localized
        self.addSubview(teamLabel)
        self.addSubview(teamField)
        nextKeyViews.append(teamField)
        
        // MARK: project
        y = y - gapTop - labelHeight
        
        let projectLabel = NSTextField(labelWithString: "\(data.displayName(key: "project")):")
        projectLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        projectLabel.alignment = .right
        projectLabel.lineBreakMode = .byClipping
        
        let projectField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        projectField.identifier = NSUserInterfaceItemIdentifier(rawValue: "project")
        projectField.usesSingleLineMode = true
        projectField.lineBreakMode = .byTruncatingTail
        projectField.delegate = data
        projectField.stringValue = data.project
        self.addSubview(projectLabel)
        self.addSubview(projectField)
        nextKeyViews.append(projectField)
        
        // MARK: repoId
        y = y - gapTop - labelHeight
        
        let repoIdLabel = NSTextField(labelWithString: "\(data.displayName(key: "repoId")):")
        repoIdLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        repoIdLabel.alignment = .right
        repoIdLabel.lineBreakMode = .byClipping
        
        let repoIdField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        repoIdField.identifier = NSUserInterfaceItemIdentifier(rawValue: "repoId")
        repoIdField.usesSingleLineMode = true
        repoIdField.lineBreakMode = .byTruncatingTail
        repoIdField.delegate = data
        repoIdField.intValue = data.repoId
        self.addSubview(repoIdLabel)
        self.addSubview(repoIdField)
        nextKeyViews.append(repoIdField)
        
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
        repoField.stringValue = data.repo
        self.addSubview(repoLabel)
        self.addSubview(repoField)
        nextKeyViews.append(repoIdField)
        
        // MARK: userId
        y = y - gapTop - labelHeight
        
        let userIdLabel = NSTextField(labelWithString: "\(data.displayName(key: "userId")):")
        userIdLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        userIdLabel.alignment = .right
        userIdLabel.lineBreakMode = .byClipping
        
        let userIdField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        userIdField.identifier = NSUserInterfaceItemIdentifier(rawValue: "userId")
        userIdField.usesSingleLineMode = true
        userIdField.lineBreakMode = .byTruncatingTail
        userIdField.delegate = data
        userIdField.intValue = data.userId
        self.addSubview(userIdLabel)
        self.addSubview(userIdField)
        nextKeyViews.append(userIdField)
        
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
        branchField.stringValue = data.branch
        self.addSubview(branchLabel)
        self.addSubview(branchField)
        nextKeyViews.append(branchField)
        
        // MARK: Token
        y = y - gapTop - labelHeight
        
        let tokenLabel = NSTextField(labelWithString: "\(data.displayName(key: "personalAccessToken")):")
        tokenLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        tokenLabel.alignment = .right
        tokenLabel.lineBreakMode = .byClipping
        
        let tokenField = NSSecureTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        tokenField.identifier = NSUserInterfaceItemIdentifier(rawValue: "personalAccessToken")
        tokenField.usesSingleLineMode = true
        tokenField.lineBreakMode = .byTruncatingTail
        tokenField.delegate = data
        tokenField.stringValue = data.personalAccessToken
        self.addSubview(tokenLabel)
        self.addSubview(tokenField)
        nextKeyViews.append(tokenField)
        
        
        // MARK: domain
//        y = y - gapTop - labelHeight
//        self.createDomainField(data)
//        self.domainField?.placeholderString = "Can be empty, there is a default domain".localized
        
        // MARK: saveKeyPath
        y = y - gapTop - labelHeight
        self.createSaveKeyField(data)
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/coding")
    }
    
}
