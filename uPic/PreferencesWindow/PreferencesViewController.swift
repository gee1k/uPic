//
//  PrefsViewController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        
    }
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
//        self.view.translatesAutoresizingMaskIntoConstraints = false
//        NSAnimationContext.current.allowsImplicitAnimation = true

        NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 2
//            context.allowsImplicitAnimation = true
//
//            self.view.layoutSubtreeIfNeeded()
            self.view.animator().setFrameSize(self.preferredContentSize)

        }, completionHandler: nil)
    }

    
}
