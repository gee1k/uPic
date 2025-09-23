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
        
        label.stringValue = "Processing files...".localized
        self.timerLabel.stringValue = "Please wait...".localized
        okButton.title = "OK".localized

        processSelectedFiles { success in
            DispatchQueue.main.async {
                if success {
                    self.label.stringValue = "Success".localized
                    self.timerLabel.stringValue = "Launching uPic...".localized
                    
                    // 使用特定标记调起主应用
                    if let url = URL(string: "uPic://share-extension-upload") {
                        NSWorkspace.shared.open(url)
                    }
                    
                    // 成功后短暂延迟关闭
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
                        self.extensionContext!.cancelRequest(withError: cancelError)
                    }
                } else {
                    self.label.stringValue = "Failed to process files".localized
                    self.timerLabel.stringValue = "Please try again".localized
                    
                    // 失败后 3 秒关闭
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
                        self.extensionContext!.cancelRequest(withError: cancelError)
                    }
                }
            }
        }
    }
    
    func processSelectedFiles(completion: @escaping (Bool) -> Void) {
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        var sharedFileURLs: [URL] = []
        var processedCount = 0
        
        guard let itemProviders = item.attachments, !itemProviders.isEmpty else {
            completion(false)
            return
        }
        
        for itemProvider in itemProviders {
            if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (data, error) in
                    defer {
                        processedCount += 1
                        if processedCount == itemProviders.count {
                            // 所有文件处理完成
                            if !sharedFileURLs.isEmpty {
                                FinderUtil.saveSharedFiles(sharedFileURLs)
                                completion(true)
                            } else {
                                completion(false)
                            }
                        }
                    }
                    
                    if let error = error {
                        debugPrint("加载文件项失败: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let nsData = data as? NSData,
                          let originalURL = NSURL(dataRepresentation: nsData as Data, relativeTo: nil) as URL? else {
                        debugPrint("无法解析文件URL")
                        return
                    }
                    
                    // 复制文件到共享目录
                    if let sharedURL = FinderUtil.copyFileToSharedDirectory(originalURL) {
                        sharedFileURLs.append(sharedURL)
                        debugPrint("文件已复制到共享目录: \(sharedURL.path)")
                    } else {
                        debugPrint("复制文件到共享目录失败: \(originalURL.path)")
                    }
                }
            } else {
                processedCount += 1
                if processedCount == itemProviders.count {
                    completion(!sharedFileURLs.isEmpty)
                }
            }
        }
    }
    
    @IBAction func didClickOKButton(_ sender: NSButton) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }
}
