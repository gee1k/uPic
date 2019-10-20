//
//  ImgurConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/8/17.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class ImgurConfigView: ConfigView {
    
    override func createView() {
        
        guard let data = self.data as? ImgurHostConfig else {
            return
        }
        
        let paddingTop = 50, paddingLeft = 6, gapTop = 10, gapLeft = 5, labelWidth = 75, labelHeight = 20,
        viewWidth = Int(self.frame.width), viewHeight = Int(self.frame.height),
        textFieldX = labelWidth + paddingLeft + gapLeft, textFieldWidth = viewWidth - paddingLeft - textFieldX
        
        var y = viewHeight - paddingTop
      
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
        let helpBtn = NSButton(title: "", target: self, action: #selector(openTutorial(_:)))
        let helpBtnWidth = Int(helpBtn.frame.width)
        helpBtn.frame = NSRect(x: viewWidth - helpBtnWidth * 3 / 2, y: y, width: helpBtnWidth, height: Int(helpBtn.frame.height))
        helpBtn.bezelStyle = .helpButton
        helpBtn.setButtonType(.momentaryPushIn)
        helpBtn.toolTip = "https://blog.svend.cc/upic/tutorials/imgur"
        self.addSubview(helpBtn)
    }
    
}
