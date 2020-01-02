//
//  GithubConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class GithubConfigView: ConfigView {
    
    override var gapTop: Int {
        return 5
    }
    
    deinit {
        PreferencesNotifier.removeObserver(observer: self, notification: .githubCDNAutoComplete)
    }
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? GithubHostConfig else {
            return
        }
        PreferencesNotifier.addObserver(observer: self, selector: #selector(autoCompleteCDN), notification: .githubCDNAutoComplete)
        
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
        
        // MARK: Use CDN
        y = y - gapTop - labelHeight
        
        let useCdnLabel = NSTextField(labelWithString: data.displayName(key: "useCdn"))
        useCdnLabel.frame = NSRect(x: viewWidth - 25 - Int(useCdnLabel.frame.width), y: y, width: Int(useCdnLabel.frame.width), height: labelHeight)
        useCdnLabel.alignment = .right
        useCdnLabel.lineBreakMode = .byClipping
        
        
        let useCdnBtn = NSButton(frame: NSRect(x: viewWidth - 25, y: y, width: 50, height: labelHeight))
        useCdnBtn.title = ""
        useCdnBtn.target = self
        useCdnBtn.action = #selector(useCdnChanged(_:))
        useCdnBtn.identifier = NSUserInterfaceItemIdentifier(rawValue: "useCdn")
        useCdnBtn.setButtonType(.switch)
        useCdnBtn.allowsMixedState = false
        useCdnBtn.state = NSControl.StateValue(rawValue: Int(data.useCdn) ?? 0)
        self.addSubview(useCdnLabel)
        self.addSubview(useCdnBtn)
        self.useCdnChanged(useCdnBtn)
       
        // MARK: saveKeyPath
        y = y - gapTop - labelHeight
        self.createSaveKeyField(data)
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/github")
    }
    
    
    @objc func useCdnChanged(_ sender: NSButton) {
        let value = sender.state.rawValue
        if value == 0 {
            self.domainField?.isEnabled = true
        } else {
            self.domainField?.isEnabled = false
            self.autoCompleteCDN()
        }
        
        let strValue = String(value)
        
        if self.data?.value(forKey: "useCdn") as? String != strValue {
            self.data?.setValue(strValue, forKey: "useCdn")
        }
        
    }
    
    /// auto complete cdn domain
    @objc func autoCompleteCDN() {
        var owner = self.data?.value(forKey: "owner") as? String
        if owner == nil || owner!.isEmpty {
            owner = "{owner}"
        }
        var repo = self.data?.value(forKey: "repo") as? String
        if repo == nil || repo!.isEmpty {
            repo = "{repo}"
        }
        var branch = self.data?.value(forKey: "branch") as? String
        if branch == nil || branch!.isEmpty {
            branch = "{branch}"
        }
        let domain = "https://cdn.jsdelivr.net/gh/\(owner!)/\(repo!)@\(branch!)"
        
        if self.domainField?.stringValue != domain {
            self.domainField?.stringValue = domain
            self.data?.setValue(domain, forKey: "domain")
        }
    }
    
}

