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

        let versionObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        versionLabel.stringValue = versionObject as? String ?? ""
    }

    @IBAction func githubButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/gee1k/uPic") else {
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
    
    @IBAction func alipayButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/gee1k/uPic/blob/master/screenshot/qrcode/alipay-mini.jpeg") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func weChatPayButtonClicked(_ sender: NSButton) {
        guard let url = URL(string: "https://github.com/gee1k/uPic/blob/master/screenshot/qrcode/wechat-mini.jpeg") else { return }
        NSWorkspace.shared.open(url)
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
