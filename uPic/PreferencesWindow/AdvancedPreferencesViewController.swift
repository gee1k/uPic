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
    }

    // MARK: Button Actions

    @IBAction func resetPreferencesButtonClicked(_ sender: NSButton) {
        let alert = NSAlert()

        alert.messageText = "Reset User Preferences?".localized
        alert.informativeText = "⚠️ Note that this will reset all user preferences".localized

        // Add button and avoid the focus ring
        let cancelString = "Cancel".localized
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true

        let yesString = "Yes".localized
        alert.addButton(withTitle: yesString).refusesFirstResponder = true

        let modalResult = alert.runModal()

        switch modalResult {
        case .alertFirstButtonReturn:
            print("Cancel Resetting User Preferences")
        case .alertSecondButtonReturn:
            SMLoginItemSetEnabled(Constants.launcherAppIdentifier as CFString, false)
            ConfigManager.shared.removeAllUserDefaults()
            ConfigManager.shared.firstSetup()
            _ = NSApplication.shared.delegate as! AppDelegate
//            appDelegate.setStatusToggle()
        default:
            print("Cancel Resetting User Preferences")
        }
    }

}
