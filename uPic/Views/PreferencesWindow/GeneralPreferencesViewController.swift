//
//  GeneralPreferencesViewController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import LaunchAtLogin

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
        LaunchAtLogin.isEnabled = sender.state == .on ? true : false
    }

    @IBAction func didClickDownloadOnAppStoreButton(_ sender: NSButton) {
        if let url = URL(string: "itms-apps://apps.apple.com/app/id1510718678") {
            NSWorkspace.shared.open(url)
        }
    }
    func refreshButtonState() {
        launchButton.state = LaunchAtLogin.isEnabled == true ? .on : .off
    }
}
