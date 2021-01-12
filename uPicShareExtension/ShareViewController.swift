//
//  ShareViewController.swift
//  uPicShareExtension
//
//  Created by Licardo on 2021/1/12.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa

class ShareViewController: NSViewController {
    
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var okButton: NSButton!
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }
    
    override func loadView() {
        super.loadView()
        var times = 3
        
        label.stringValue = "Unsupported file type".localized
        self.timerLabel.stringValue = "closing in %@ seconds...".localized
        self.timerLabel.stringValue = self.timerLabel.stringValue.replacingOccurrences(of: "%@", with: "\(times)")
        okButton.title = "OK".localized
        
        let time = DispatchSource.makeTimerSource()
        time.schedule(deadline: .now(), repeating: 1) //repeating代表间隔1秒
        time.setEventHandler {
            if times == 0 {
                time.cancel()
                let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
                self.extensionContext!.cancelRequest(withError: cancelError)
            }else {
                DispatchQueue.main.async {
                    self.timerLabel.stringValue = "closing in %@ seconds...".localized
                    self.timerLabel.stringValue = self.timerLabel.stringValue.replacingOccurrences(of: "%@", with: "\(times)")
                    times -= 1
                }
            }
        }

        getSelectedItemsURL { (paths) in
            let encodeUrl = "uPic://files?\(paths)".urlEncoded()

            if let url = URL(string: encodeUrl) {
                self.label.stringValue = "Success".localized
                NSWorkspace.shared.open(url)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            time.resume()
        }
    }
    
    func getSelectedItemsURL(callback: @escaping (_ paths: String)->()) {
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        var paths = ""
        var i = 0
        
        if let itemProviders = item.attachments {
            for itemProvider in itemProviders {
                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (data, error) in
                        let nsData = data as! NSData
                        let url = NSURL(dataRepresentation: nsData as Data, relativeTo: nil)
                        var filePath = url.absoluteString!
                        
                        if filePath.starts(with: "file://") {
                            filePath = String(filePath.dropFirst(7)) // 去除文件开头的"file://"
                        }
                        paths = "\(paths)\(filePath)\n"
                        
                        i += 1
                        if i == itemProviders.count {
                            callback(paths)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func didClickOKButton(_ sender: NSButton) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }
}
