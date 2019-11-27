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
    @IBOutlet weak var historyRecordWidth: NSTextField!
    @IBOutlet weak var historyRecordColumns: NSTextField!
    @IBOutlet weak var historyRecordSpacing: NSTextField!
    @IBOutlet weak var historyRecordPadding: NSTextField!
    @IBOutlet weak var historyRecordFileNameScrollSpeed: NSTextField!
    @IBOutlet weak var historyRecordFileNameScrollWaitTime: NSTextField!
    @IBOutlet weak var resetPreferencesButton: NSButton!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        selectFileShortcut.associatedUserDefaultsKey = Constants.Key.selectFileShortcut
        pasteboardShortcut.associatedUserDefaultsKey = Constants.Key.pasteboardShortcut
        screenshotShortcut.associatedUserDefaultsKey = Constants.Key.screenshotShortcut
        
        setHistoryRecordTextFieldDefaultText()
    }
    
    func setHistoryRecordTextFieldDefaultText() {
        historyRecordWidth.stringValue = "\(Defaults[.historyRecordWidth]!)"
        historyRecordColumns.stringValue = "\(Defaults[.historyRecordColumns]!)"
        historyRecordSpacing.stringValue = "\(Defaults[.historyRecordSpacing]!)"
        historyRecordPadding.stringValue = "\(Defaults[.historyRecordPadding]!)"
        historyRecordFileNameScrollSpeed.stringValue = "\(Defaults[.historyRecordFileNameScrollSpeed]!)"
        historyRecordFileNameScrollWaitTime.stringValue = "\(Defaults[.historyRecordFileNameScrollWaitTime]!)"
    }


    @IBAction func didClickHistoryRecordConfigurationSaveButton(_ sender: NSButton) {
        Defaults[.historyRecordWidth] = Float(historyRecordWidth.stringValue)
        Defaults[.historyRecordColumns] = Int(historyRecordColumns.stringValue)
        Defaults[.historyRecordSpacing] = Float(historyRecordSpacing.stringValue)
        Defaults[.historyRecordPadding] = Float(historyRecordPadding.stringValue)
        Defaults[.historyRecordFileNameScrollSpeed] = Double(historyRecordFileNameScrollSpeed.stringValue)
        Defaults[.historyRecordFileNameScrollWaitTime] = Float(historyRecordFileNameScrollWaitTime.stringValue)
        
        ConfigNotifier.postNotification(.changeHistoryList)
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
