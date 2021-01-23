//
//  ScreenshotAuthorizationHelpViewController.swift
//  uPic
//
//  Created by Svend Jin on 2021/1/24.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa

class ScreenshotAuthorizationHelpViewController: NSViewController {
    
    @IBOutlet weak var openPreferencesButton: NSButton!
    
    @IBAction func didClickopenPreferencesButton(_ sender: NSButton) {
        ScreenUtil.openPrivacyScreenCapture()
    }
}
