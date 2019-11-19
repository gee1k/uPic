//
//  ConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class ConfigView: NSView {
    
    var settings: Bool {
        return true
    }
    // 创建配置界面
    static func createConfigView(parentView: NSView, item: Host) {
        // MARK: 根据当前选择的图床，创建对应的配置界面
        switch item.type {
        case .custom:
            parentView.addSubview(CustomConfigView(frame: parentView.frame, data: item.data))
            break
        case .upyun_USS:
            parentView.addSubview(UpYunConfigView(frame: parentView.frame, data: item.data))
            break
        case .qiniu_KODO:
            parentView.addSubview(QiniuConfigView(frame: parentView.frame, data: item.data))
            break
        case .aliyun_OSS:
            parentView.addSubview(AliyunConfigView(frame: parentView.frame, data: item.data))
            break
        case .tencent_COS:
            parentView.addSubview(TencentConfigView(frame: parentView.frame, data: item.data))
            break
        case .github:
            parentView.addSubview(GithubConfigView(frame: parentView.frame, data: item.data))
            break
        case .gitee:
            parentView.addSubview(GiteeConfigView(frame: parentView.frame, data: item.data))
            break
        case .weibo:
            parentView.addSubview(WeiboConfigView(frame: parentView.frame, data: item.data))
            break
        case .amazon_S3:
            parentView.addSubview(AmazonS3ConfigView(frame: parentView.frame, data: item.data))
            break
        case .imgur:
            parentView.addSubview(ImgurConfigView(frame: parentView.frame, data: item.data))
            break
        case .baidu_BOS:
            parentView.addSubview(BaiduConfigView(frame: parentView.frame, data: item.data))
            break
        default:
            let label = NSTextField(labelWithString: "The file will be uploaded anonymously to".localized + " \(item.name)")
            label.frame = NSRect(x: (parentView.frame.width - label.frame.width) / 2, y: parentView.frame.height - 50, width: label.frame.width, height: 20)
            parentView.addSubview(label)
        }
    }
    
    var data: HostConfig?
    
    var domainField: NSTextField?
    
    var configSheetController: ConfigSheetController?
    
    var nextKeyViews:[NSView] = [NSView]()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        self.createView()
        
        self.setNextKeyViews()
        
        if self.settings {
            configSheetController = (self.window?.contentViewController?.storyboard!.instantiateController(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ConfigSheetController").rawValue)
                as! ConfigSheetController)
        }
    }
    
    
    init(frame frameRect: NSRect, data: HostConfig?) {
        super.init(frame: frameRect)
        
        self.data = data
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        configSheetController?.removeFromParent()
    }
    
    func createView() {
        // Subclasses override
    }
    
    func createHelpBtn(_ paddingRight: Int, _ y: Int, _ url: String) {
        let helpBtn = NSButton(title: "", target: self, action: #selector(openTutorial(_:)))
        let helpBtnWidth = Int(helpBtn.frame.width)
        helpBtn.frame = NSRect(x: Int(self.frame.width) - helpBtnWidth - paddingRight, y: y, width: helpBtnWidth, height: Int(helpBtn.frame.height))
        helpBtn.title = ""
        helpBtn.bezelStyle = .helpButton
        helpBtn.imagePosition = .imageOnly
        helpBtn.setButtonType(.momentaryPushIn)
        helpBtn.toolTip = url
        self.addSubview(helpBtn)
    }
    
    func setNextKeyViews() {
        if nextKeyViews.count > 1 {
            for (index, item) in nextKeyViews.enumerated() {
                let currentView = item
                if index == nextKeyViews.count - 1 {
                    break
                }
                
                let nextView = nextKeyViews[index + 1]
                currentView.nextKeyView = nextView
                
            }
        }
    }
    
    @objc func openTutorial(_ sender: NSButton) {
        guard let urlStr = sender.toolTip, let url = URL(string: urlStr) else {
            return
        }
        NSWorkspace.shared.open(url)
    }
    
    func addObserver() {
        PreferencesNotifier.addObserver(observer: self, selector: #selector(saveHostSettings), notification: PreferencesNotifier.Notification.saveHostSettings)
    }
    
    
    func removeObserver() {
        PreferencesNotifier.removeObserver(observer: self, notification: .saveHostSettings)
    }
    
    @objc func openConfigSheet(_ sender: NSButton) {
        if let configSheetController = configSheetController {
            var userInfo: [String: Any] = ["domain": self.data?.value(forKey: "domain") ?? "", "folder": self.data?.value(forKey: "folder") ?? "", "saveKey": self.data?.value(forKey: "saveKey") ?? HostSaveKey.dateFilename.rawValue]
            
            if self.data?.containsKey(key: "suffix") ?? false {
                userInfo["suffix"] = self.data?.value(forKey: "suffix") ?? ""
            }
            
            self.window?.contentViewController?.presentAsSheet(configSheetController)
            configSheetController.setData(userInfo: userInfo as [String: AnyObject])
            self.addObserver()
        }
        
    }
    
    @objc func saveHostSettings(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print("No userInfo found in notification")
            return
        }
        
        let domain = userInfo["domain"] as? String ?? ""
        let folder = userInfo["folder"] as? String ?? ""
        let saveKey = userInfo["saveKey"] as? String ?? HostSaveKey.dateFilename.rawValue
        
        self.data?.setValue(domain, forKey: "domain")
        self.data?.setValue(folder, forKey: "folder")
        self.data?.setValue(saveKey, forKey: "saveKey")
        
        if self.data?.containsKey(key: "suffix") ?? false {
            let suffix = userInfo["suffix"] as? String ?? ""
            self.data?.setValue(suffix, forKey: "suffix")
        }
        
        domainField?.stringValue = domain
    }
    
}
