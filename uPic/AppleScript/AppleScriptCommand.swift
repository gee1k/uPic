//
//  AppleScriptCommand.swift
//  uPic
//
//  Created by Licardo on 2021/6/6.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa

@objc(AppleScriptCommand) class AppleScriptCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        
        if let fileURL = directParameter as? NSString {
            let encodeUrl = "uPic://files?\(fileURL)".urlEncoded()
            
            if let url = URL(string: encodeUrl) {
                NSWorkspace.shared.open(url)
            }
        }
        
        return nil
    }
}

