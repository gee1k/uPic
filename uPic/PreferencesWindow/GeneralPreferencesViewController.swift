//
//  GeneralPreferencesViewController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import LoginServiceKit

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
        if sender.state == .on {
            LoginServiceKit.addLoginItems()
        } else if sender.state == .off {
            LoginServiceKit.removeLoginItems()
        }
    }

    func refreshButtonState() {
        launchButton.state = LoginServiceKit.isExistLoginItems() ? .on : .off
    }
}
