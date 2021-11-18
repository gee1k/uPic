//
//  AboutPreferencesViewController.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/11.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class AboutPreferencesViewController: PreferencesViewController {
    
    @IBOutlet weak var versionLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let versionNum = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let buildNum = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        versionLabel.stringValue = "v\(versionNum) (\(buildNum))"
    }
    
    @IBAction func githubButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/gee1k/uPic") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func twitterButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://twitter.com/realSvend") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func tgButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://t.me/upic_host") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func homePageButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://svend.cc") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func contactButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "mailto:svend.jin@gmail.com?subject=uPic%20Feedback") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func didClickShowWelcomePageButton(_ sender: NSButton) {
        _ = WindowManager.shared.showWindow(storyboard: "Welcome", withIdentifier: "welcomeWindowController")
    }
}

class LinkButton: NSButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func resetCursorRects() {
        addCursorRect(self.bounds, cursor: .pointingHand)
    }
}
