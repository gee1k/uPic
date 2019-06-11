//
//  StatusMenuController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import MASShortcut

class StatusMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    @IBOutlet weak var selectFileMenuItem: NSMenuItem!
    @IBOutlet weak var uploadPasteboardMenuItem: NSMenuItem!
    @IBOutlet weak var screenshotMenuItem: NSMenuItem!
    @IBOutlet weak var ouputFormatMenuItem: NSMenuItem!
    @IBOutlet weak var preferenceMenuItem: NSMenuItem!
    @IBOutlet weak var checkUpdateMenuItem: NSMenuItem!
    @IBOutlet weak var quitMenuItem: NSMenuItem!
    
    override func awakeFromNib() {
        selectFileMenuItem.title = NSLocalizedString("status-menu.select-file", comment: "Select file")
        
        uploadPasteboardMenuItem.title = NSLocalizedString("status-menu.pasteboard", comment: "Upload with pasteboard")
        screenshotMenuItem.title = NSLocalizedString("status-menu.screenshot", comment: "Upload with pasteboard")
        ouputFormatMenuItem.title = NSLocalizedString("status-menu.output", comment: "Choose output format")
        preferenceMenuItem.title = NSLocalizedString("status-menu.preference", comment: "Open Preference")
        checkUpdateMenuItem.title = NSLocalizedString("status-menu.check-update", comment: "Check update")
        quitMenuItem.title = NSLocalizedString("status-menu.quit", comment: "Quit")
        
        refreshOutputFormat()
    }
    
    @IBAction func selectFileMenuItemClicked(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.selectFile()
    }
    
    @IBAction func uploadPasteboardMenuItemClicked(_ sender: NSMenuItem) {
         (NSApplication.shared.delegate as? AppDelegate)?.uploadByPasteboard()
    }
    
    @IBAction func screenshotMenuItemClicked(_ sender: NSMenuItem) {
         (NSApplication.shared.delegate as? AppDelegate)?.screenshotAndUpload()
    }
    
    @IBAction func preferenceMenuItemClicked(_ sender: NSMenuItem) {
         (NSApplication.shared.delegate as? AppDelegate)?.showPreference()
    }
    
    @IBAction func checkUpdateMenuItemClicked(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.checkUpdate()
    }
    
    @IBAction func quitMenuItemClicked(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }
    
    
    @IBAction func ouputFormatMenuItemClicked(_ sender: NSMenuItem) {
        (NSApplication.shared.delegate as? AppDelegate)?.setOutputFomart(format: sender.tag)
        self.refreshOutputFormat()
    }
    
    func refreshOutputFormat() {
        let outputFormat =  (NSApplication.shared.delegate as? AppDelegate)?.getOutputFormat()
        for item in ouputFormatMenuItem.submenu!.items {
            if item.tag == outputFormat {
                item.state = .on
            } else {
                item.state = .off
            }
        }
    }
}
