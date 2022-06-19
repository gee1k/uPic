//
//  SmmsConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/30.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class SmmsConfigView: ConfigView {
    
    var tokenLabel: NSTextField!
    var tokenField: NSSecureTextField!
    var tokenBtn: NSButton!
    
    override var paddingTop: Int {
        return 50
    }
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? SmmsHostConfig else {
            return
        }
      
        // MARK: Token
        tokenLabel = NSTextField(labelWithString: "\(data.displayName(key: "token")):")
        tokenLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        tokenLabel.alignment = .right
        tokenLabel.lineBreakMode = .byClipping
        
        tokenField = NSSecureTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        tokenField.identifier = NSUserInterfaceItemIdentifier(rawValue: "token")
        tokenField.usesSingleLineMode = true
        tokenField.lineBreakMode = .byTruncatingTail
        tokenField.delegate = data
        tokenField.stringValue = data.token ?? ""
        self.addSubview(tokenLabel)
        self.addSubview(tokenField)
        nextKeyViews.append(tokenField)
        
        // Get API Token
        
        y = y - gapTop - labelHeight
        tokenBtn = NSButton(title: "Get API Token".localized, target: self, action: #selector(getApiToken(_:)))
        let tokenBtnWidth = Int(tokenBtn.frame.width)
        tokenBtn.frame = NSRect(x: Int(self.frame.width) - tokenBtnWidth, y: y, width: tokenBtnWidth, height: Int(tokenBtn.frame.height))
        self.addSubview(tokenBtn)
        
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/smms")
    }
    
    @objc func getApiToken(_ sender: NSButton) {
        guard let url = URL(string: "https://sm.ms/home/apitoken") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
}
