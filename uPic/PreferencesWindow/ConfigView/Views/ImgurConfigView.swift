//
//  ImgurConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/8/17.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class ImgurConfigView: ConfigView {
    
    override init(frame frameRect: NSRect, data: HostConfig?) {
        super.init(frame: frameRect, data: data)
        
        self.paddingTop = 50
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createView() {
        super.createView()
        
        guard let data = self.data as? ImgurHostConfig else {
            return
        }
        
      
        // MARK: clientId
        let clientIdLabel = NSTextField(labelWithString: "\(data.displayName(key: "clientId")):")
        clientIdLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        clientIdLabel.alignment = .right
        clientIdLabel.lineBreakMode = .byClipping
        
        let clientIdField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        clientIdField.identifier = NSUserInterfaceItemIdentifier(rawValue: "clientId")
        clientIdField.usesSingleLineMode = true
        clientIdField.lineBreakMode = .byTruncatingTail
        clientIdField.delegate = data
        clientIdField.stringValue = data.clientId ?? ""
        self.addSubview(clientIdLabel)
        self.addSubview(clientIdField)
        nextKeyViews.append(clientIdField)
        
        // MARK: help
        y = y - gapTop * 2 - labelHeight
        super.createHelpBtn("https://blog.svend.cc/upic/tutorials/imgur")
    }
    
}
