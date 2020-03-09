//
//  AdvancedPreferencesViewController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
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
    @IBOutlet weak var finderExtensionIcon: NSPopUpButton!
    @IBOutlet weak var resetPreferencesButton: NSButton!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetAllValues()
    }
    
    func resetAllValues() {
        selectFileShortcut.associatedUserDefaultsKey = Constants.Key.selectFileShortcut
        pasteboardShortcut.associatedUserDefaultsKey = Constants.Key.pasteboardShortcut
        screenshotShortcut.associatedUserDefaultsKey = Constants.Key.screenshotShortcut
        
        setHistoryRecordTextFieldDefaultText()
        setFinderExtensionIconDefaultValue()
    }
    
    func setHistoryRecordTextFieldDefaultText() {
        historyRecordWidth.stringValue = "\(HistoryRecordWidthGlobal)"
        historyRecordColumns.stringValue = "\(HistoryRecordColumnsGlobal)"
        historyRecordSpacing.stringValue = "\(HistoryRecordSpacingGlobal)"
        historyRecordPadding.stringValue = "\(HistoryRecordPaddingGlobal)"
        historyRecordFileNameScrollSpeed.stringValue = "\(HistoryRecordFileNameScrollSpeedGlobal)"
        historyRecordFileNameScrollWaitTime.stringValue = "\(HistoryRecordFileNameScrollWaitTimeGlobal)"
    }
    
    func setFinderExtensionIconDefaultValue() {
        finderExtensionIcon.selectItem(at: FinderUtil.getIcon())
    }

    @IBAction func didClickHistoryRecordConfigurationResetButton(_ sender: NSButton) {
        
        Defaults.removeObject(forKey: Keys.historyRecordWidth)
        Defaults.removeObject(forKey: Keys.historyRecordColumns)
        Defaults.removeObject(forKey: Keys.historyRecordSpacing)
        Defaults.removeObject(forKey: Keys.historyRecordPadding)
        Defaults.removeObject(forKey: Keys.historyRecordFileNameScrollSpeed)
        Defaults.removeObject(forKey: Keys.historyRecordFileNameScrollWaitTime)
        Defaults.synchronize()
        
        DispatchQueue.main.async {
            self.setHistoryRecordTextFieldDefaultText()
            ConfigNotifier.postNotification(.changeHistoryList)
        }
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

    @IBAction func didChangeFinderExtensionIcon(_ sender: NSPopUpButton) {
        FinderUtil.setIcon(sender.indexOfSelectedItem)
    }
    
    @IBAction func didClickRestartFinder(_ sender: NSButton) {
        let killFinderScript = #"do shell script "killall Finder""#
        let script = NSAppleScript(source: killFinderScript)
        script!.executeAndReturnError(nil)
    }
    
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
            ConfigManager.shared.removeAllUserDefaults()
            ConfigManager.shared.firstSetup()
            FinderUtil.removeIcon()
            
            DispatchQueue.main.async {
                self.setFinderExtensionIconDefaultValue()
                ConfigNotifier.postNotification(.changeHistoryList)
                self.resetAllValues()
            }
            
        default:
            print("Cancel Resetting User Preferences")
        }
    }

}
