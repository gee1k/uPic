//
//  GeneralPreferencesViewController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import ServiceManagement

class GeneralPreferencesViewController: PreferencesViewController {

    // MARK: Properties

    @IBOutlet weak var launchButton: NSButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        refreshButtonState()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    @IBAction func launchButtonClicked(_ sender: NSButton) {
        let isLaunch = launchButton.state == .on
        let launchAtLogin: BoolType = isLaunch ? ._true : ._false
        CoreManager.shared.launchAtLogin = launchAtLogin
        SMLoginItemSetEnabled(Constants.launcherAppIdentifier as CFString, isLaunch)
    }
    
    func refreshButtonState() {
        guard let launchAtLogin = CoreManager.shared.launchAtLogin else { return }
        launchButton.state = launchAtLogin == ._true ? .on : .off
    }
}
