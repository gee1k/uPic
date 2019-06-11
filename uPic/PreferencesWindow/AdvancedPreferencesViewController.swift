//
//  AdvancedPreferencesViewController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import ServiceManagement
import MASShortcut

class AdvancedPreferencesViewController: PreferencesViewController {

    @IBOutlet weak var selectFileShortcut: MASShortcutView!
    @IBOutlet weak var pasteboardShortcut: MASShortcutView!
    @IBOutlet weak var screenshotShortcut: MASShortcutView!
    @IBOutlet weak var resetPreferencesButton: NSButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectFileShortcut.associatedUserDefaultsKey = Constants.Key.selectFileShortcut
        pasteboardShortcut.associatedUserDefaultsKey = Constants.Key.pasteboardShortcut
        screenshotShortcut.associatedUserDefaultsKey = Constants.Key.screenshotShortcut
        
        bindShortcuts()
    }
    
    func bindShortcuts() {
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: Constants.Key.selectFileShortcut) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.selectFile()
        }
        
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: Constants.Key.pasteboardShortcut) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.uploadByPasteboard()
        }
        
        MASShortcutBinder.shared()?.bindShortcut(withDefaultsKey: Constants.Key.screenshotShortcut) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.screenshotAndUpload()
        }
    }
    
    // MARK: Button Actions
    
    @IBAction func resetPreferencesButtonClicked(_ sender: NSButton) {
        let alert = NSAlert()
        
        alert.messageText = NSLocalizedString("alert.reset_preferences_title", comment: "Reset User Preferences?")
        alert.informativeText = NSLocalizedString("alert.reset_preferences_description", comment: "⚠️ Note that this will reset all user preferences")
        
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        
        let yesString = NSLocalizedString("general.yes", comment: "Yes")
        alert.addButton(withTitle: yesString).refusesFirstResponder = true
        
        let modalResult = alert.runModal()
        
        switch modalResult {
        case .alertFirstButtonReturn:
            print("Cancel Resetting User Preferences")
        case .alertSecondButtonReturn:
            SMLoginItemSetEnabled(Constants.launcherAppIdentifier as CFString, false)
            CoreManager.shared.removeAllUserDefaults()
            CoreManager.shared.firstSetup()
            _ = NSApplication.shared.delegate as! AppDelegate
//            appDelegate.setStatusToggle()
        default:
            print("Cancel Resetting User Preferences")
        }
    }
    
}
