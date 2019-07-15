//
//  CustomConfigSheetController.swift
//  uPic
//
//  Created by Svend Jin on 2019/7/14.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class CustomConfigSheetController: NSViewController {

    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var okButton: NSButton!
    
    @IBOutlet weak var addHeaderButton: NSButton!
    @IBOutlet weak var addBodyButton: NSButton!
    @IBOutlet weak var scrollView: NSScrollView!
    
    var headers:Dictionary<String, String>?;
    var bodys:Dictionary<String, String>?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        okButton.highlight(true)
    }


    @IBAction func addHeaderBtnClicked(_ sender: Any) {
        
    }

    @IBAction func addBodyBtnClicked(_ sender: Any) {
    }
    
    @IBAction func okBtnClicked(_ sender: Any) {
        self.dismiss(sender)
    }
    
    func refreshScroolView() {
        
    }
}
