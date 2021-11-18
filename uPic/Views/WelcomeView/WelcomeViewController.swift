//
//  WelcomViewController.swift
//  uPic
//
//  Created by Licardo on 2021/1/19.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Cocoa

class WelcomViewController: NSViewController {
    
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var previousButtonLabel: NSTextField!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var nextButtonLabel: NSTextField!
    
    // 子界面
    var currentViewIndex = 0
    let viewList = [
        WindowManager.shared.instantiateControllerFromStoryboard(storyboard: "Welcome", withIdentifier: "welcomeViewController0") as NSViewController,
        WindowManager.shared.instantiateControllerFromStoryboard(storyboard: "Welcome", withIdentifier: "welcomeViewController1") as NSViewController,
        WindowManager.shared.instantiateControllerFromStoryboard(storyboard: "Welcome", withIdentifier: "welcomeViewController2") as NSViewController,
        WindowManager.shared.instantiateControllerFromStoryboard(storyboard: "Welcome", withIdentifier: "welcomeViewController3") as NSViewController,
        WindowManager.shared.instantiateControllerFromStoryboard(storyboard: "Welcome", withIdentifier: "welcomeViewController4") as NSViewController,
        WindowManager.shared.instantiateControllerFromStoryboard(storyboard: "Welcome", withIdentifier: "welcomeViewController5") as NSViewController,
        WindowManager.shared.instantiateControllerFromStoryboard(storyboard: "Welcome", withIdentifier: "welcomeViewController6") as NSViewController
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        closeButton.alphaValue = 0.5
        
        for viewController in viewList {
            addChild(viewController)
        }
        containerView.addSubview(children[0].view)
    }
    
    @IBAction func didClickCloseButton(_ sender: NSButton) {
        closeWindow(sender)
    }
    @IBAction func didClickPreviousButton(_ sender: NSButton) {
        switchToPage(to: currentViewIndex - 1)
    }
    
    @IBAction func didClickNextButton(_ sender: NSButton) {
        if currentViewIndex == viewList.count - 1 { // 最后一个页面
            debugPrintOnly("开始授权")
            // 欢迎页授权用户主目录
            DiskPermissionManager.shared.requestHomeDirectoryPermissions()
            closeWindow(sender)
        } else {
            switchToPage(to: currentViewIndex + 1)
        }
    }
    
    func closeWindow(_ sender: Any) {
        view.window?.close()
    }
    
}

// MARK: - 界面切换
extension WelcomViewController {
    // 翻页
    func switchToPage(to targetViewIndex: Int) {
        if targetViewIndex>=0 && targetViewIndex < viewList.count {
            // 切换按钮可见性
            if targetViewIndex == 0 {
                previousButton.isHidden = true
                previousButtonLabel.isHidden = true
                nextButton.isHidden = false
                nextButtonLabel.isHidden = false
            } else if targetViewIndex == viewList.count {
                previousButton.isHidden = false
                previousButtonLabel.isHidden = false
                nextButton.isHidden = true
                nextButtonLabel.isHidden = true
            } else {
                previousButton.isHidden = false
                previousButtonLabel.isHidden = false
                nextButton.isHidden = false
                nextButtonLabel.isHidden = false
            }
            // 切换页面
            let currentViewController = viewList[currentViewIndex]
            let targetViewController = viewList[targetViewIndex]
            if targetViewIndex < currentViewIndex {
                transition(from: currentViewController, to: targetViewController, options: .slideRight, completionHandler: nil)
            } else {
                transition(from: currentViewController, to: targetViewController, options: .slideLeft, completionHandler: nil)
            }
            // 更新文本
            if targetViewIndex == viewList.count - 1 { // 最后一个页面
                nextButtonLabel.stringValue = "Authorize".localized
            } else {
                nextButtonLabel.stringValue = "Next".localized
            }
            // 更新引用
            currentViewIndex = targetViewIndex
        }
    }
}
