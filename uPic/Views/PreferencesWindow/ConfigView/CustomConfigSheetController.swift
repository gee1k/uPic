//
//  CustomConfigSheetController.swift
//  uPic
//
//  Created by Svend Jin on 2019/7/14.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON

class CustomConfigSheetController: NSViewController {

    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var okButton: NSButton!
    
    @IBOutlet weak var addHeaderButton: NSButton!
    @IBOutlet weak var addBodyButton: NSButton!
    @IBOutlet weak var scrollView: NSScrollView!
    
    var headers:Array<Dictionary<String, String>> = [];
    var bodys:Array<Dictionary<String, String>> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        okButton.highlight(true)
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
    }


    @IBAction func addHeaderBtnClicked(_ sender: Any) {
        headers.append(["key": "", "value": ""])
        self.refreshScroolView()
    }

    @IBAction func addBodyBtnClicked(_ sender: Any) {
        bodys.append(["key": "", "value": ""])
        self.refreshScroolView()
    }
    
    @IBAction func okBtnClicked(_ sender: Any) {
        let headerStr = CustomHostUtil.formatHeadersOrBodys(self.headers)
        let bodyStr = CustomHostUtil.formatHeadersOrBodys(self.bodys)
        let userInfo: [String: Any] = ["headers": headerStr, "bodys": bodyStr]
        PreferencesNotifier.postNotification(.saveCustomExtensionSettings, object: "CustomConfigSheetController", userInfo: userInfo)
        
        self.dismiss(sender)
    }
    
    func refreshScroolView() {
        let paddingLeft = 10, paddingTop = 10, gapLeft = 6, keyWidth = 130, valueWidth = 220, height = 22
        var y = paddingTop
        
        let contentView = FlippedView()
        var nextKeyViews: [NSView] = []
        
        if self.headers.count > 0 {
            let headersTitle = NSTextField(labelWithString: "Header Data".localized)
            headersTitle.setFrameOrigin(NSPoint(x: paddingLeft, y: y))
            contentView.addSubview(headersTitle)
            
            for (index, header) in self.headers.enumerated() {
                y = y + height + paddingTop
                let keyField = NSTextField(frame: NSRect(x: paddingLeft, y: y, width: keyWidth, height: height))
                keyField.identifier = NSUserInterfaceItemIdentifier(rawValue: "header-\(index)-key")
                keyField.delegate = self
                keyField.stringValue = header["key"] ?? ""
                keyField.placeholderString = "key"
                contentView.addSubview(keyField)
                nextKeyViews.append(keyField)
                
                let valueField = NSTextField(frame: NSRect(x: paddingLeft + keyWidth + gapLeft, y: y, width: valueWidth, height: height))
                valueField.identifier = NSUserInterfaceItemIdentifier(rawValue: "header-\(index)-value")
                valueField.usesSingleLineMode = true
                valueField.lineBreakMode = .byTruncatingTail
                valueField.delegate = self
                valueField.stringValue = header["value"] ?? ""
                valueField.placeholderString = "value"
                contentView.addSubview(valueField)
                nextKeyViews.append(valueField)
                
                let removeBtn = NSButton(frame: NSRect(x:  gapLeft * 2 + paddingLeft + keyWidth + valueWidth, y: y, width: height, height: height))
                removeBtn.bezelStyle = .texturedRounded
                removeBtn.identifier = NSUserInterfaceItemIdentifier(rawValue: "header-\(index)-remove_btn")
                removeBtn.image = NSImage(named: NSImage.removeTemplateName)
                removeBtn.imagePosition = .imageOnly
                removeBtn.target = self
                removeBtn.action = #selector(onRemoveItem(_:))
                contentView.addSubview(removeBtn)
            }
            
            y = y + height
        }
        
        if self.bodys.count > 0 {
            y = y + paddingTop
            
            let bodyTitle = NSTextField(labelWithString: "Body Data".localized)
            bodyTitle.setFrameOrigin(NSPoint(x: paddingLeft, y: y))
            contentView.addSubview(bodyTitle)
            
            for (index, body) in self.bodys.enumerated() {
                y = y + height + paddingTop
                let keyField = NSTextField(frame: NSRect(x: paddingLeft, y: y, width: keyWidth, height: height))
                keyField.identifier = NSUserInterfaceItemIdentifier(rawValue: "body-\(index)-key")
                keyField.delegate = self
                keyField.stringValue = body["key"] ?? ""
                keyField.placeholderString = "key"
                contentView.addSubview(keyField)
                nextKeyViews.append(keyField)
                
                let valueField = NSTextField(frame: NSRect(x: paddingLeft + keyWidth + gapLeft, y: y, width: valueWidth, height: height))
                valueField.identifier = NSUserInterfaceItemIdentifier(rawValue: "body-\(index)-value")
                valueField.usesSingleLineMode = true
                valueField.lineBreakMode = .byTruncatingTail
                valueField.delegate = self
                valueField.stringValue = body["value"] ?? ""
                valueField.placeholderString = "value"
                contentView.addSubview(valueField)
                nextKeyViews.append(valueField)
                
                let removeBtn = NSButton(frame: NSRect(x:  gapLeft * 2 + paddingLeft + keyWidth + valueWidth, y: y, width: height, height: height))
                removeBtn.bezelStyle = .texturedRounded
                removeBtn.identifier = NSUserInterfaceItemIdentifier(rawValue: "body-\(index)-remove_btn")
                removeBtn.image = NSImage(named: NSImage.removeTemplateName)
                removeBtn.imagePosition = .imageOnly
                removeBtn.target = self
                removeBtn.action = #selector(onRemoveItem(_:))
                contentView.addSubview(removeBtn)
            }
        }
        
        self.setNextKeyViews(nextKeyViews)
        
        contentView.frame = NSRect(x: 0, y: 0, width: Int(scrollView.frame.width), height: y + height + paddingTop)
        scrollView.documentView = contentView
        if let documentView = scrollView.documentView {
            if documentView.isFlipped {
                documentView.scroll(.zero)
            } else {
                let maxHeight = max(scrollView.bounds.height, documentView.bounds.height)
                documentView.scroll(NSPoint(x: 0, y: maxHeight))
            }
        }
    }
    
    func setNextKeyViews(_ nextKeyViews: [NSView]) {
        if nextKeyViews.count > 1 {
            for (index, item) in nextKeyViews.enumerated() {
                let currentView = item
                if index == nextKeyViews.count - 1 {
                    break
                }
                
                let nextView = nextKeyViews[index + 1]
                currentView.nextKeyView = nextView
                
            }
        }
    }
    
    // 删除某项
    @objc func onRemoveItem(_ sender: NSButton) {
        if let identifier = sender.identifier?.rawValue {
            let args = identifier.split(separator: Character("-"))
            let type = args[0]
            
            guard let index = Int(args[1]) else {
                return
            }
            
            if (type == "header") {
                if (index >= 0 || index < self.headers.count) {
                    self.headers.remove(at: index)
                    self.refreshScroolView()
                }
            } else if (type == "body") {
                if (index >= 0 || index < self.headers.count) {
                    self.bodys.remove(at: index)
                    self.refreshScroolView()
                }
            }
            
        }
    }
    
    func setData(headerStr: String, bodyStr: String) {
        self.headers.removeAll()
        self.bodys.removeAll()
        
        self.headers = CustomHostUtil.parseHeadersOrBodys(headerStr)
        self.bodys = CustomHostUtil.parseHeadersOrBodys(bodyStr)
        
        self.refreshScroolView()
    }
}

extension CustomConfigSheetController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, let identifier = textField.identifier?.rawValue {
            let args = identifier.split(separator: Character("-"))
            let type = args[0]
            let index = Int(args[1])!
            let field = String(args[2])
            
            if (index < 0) {
                return
            }
            
            
            let value = textField.stringValue
            let trimValue = value.trim()
            
            if (type == "header" && index < self.headers.count) {
                self.headers[index][field] = trimValue
            } else if (type == "body" && index < self.bodys.count) {
                self.bodys[index][field] = trimValue
            }
        }
    }
    
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, let identifier = textField.identifier?.rawValue {
            let args = identifier.split(separator: Character("-"))
            let type = args[0]
            let index = Int(args[1])!
            let field = String(args[2])
            
            if (index < 0) {
                return
            }
            
            
            if (type == "header" && index < self.headers.count) {
                textField.stringValue = self.headers[index][field] ?? textField.stringValue
            } else if (type == "body" && index < self.bodys.count) {
                textField.stringValue = self.bodys[index][field] ?? textField.stringValue
            }
        }
    }
}
