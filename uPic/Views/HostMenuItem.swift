//
//  HostMenuItem.swift
//  uPic
//
//  Created by Svend Jin on 2019/7/7.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class HostMenuItem: NSMenuItem {
    var hostName:String = ""
    
    init(title: String, hostName: String?, action selector: Selector?, maxhostNameLength:CGFloat) {
        super.init(title: title, action: selector, keyEquivalent: "")
        
        self.hostName = hostName ?? ""
        
        if !self.hostName.isEmpty  {
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.tabStops = [
                NSTextTab(textAlignment: .right, location: maxhostNameLength + 80, options: [:]),
            ]
            
            let str = "\(title)\t\(self.hostName)"
            
            let attributed = NSMutableAttributedString(
                string: str,
                attributes: [NSAttributedString.Key.paragraphStyle: paragraph]
            )
            
            let delayAttr = [NSAttributedString.Key.font:NSFont.menuFont(ofSize: 12)]
            attributed.addAttributes(delayAttr, range: NSRange(self.hostName.utf16.count+1 ..< str.utf16.count))
            self.attributedTitle = attributed
        }
        
        
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var isSelected:Bool = false {
        didSet {
            self.state = isSelected ? .on : .off
        }
    }
}
