//
//  ConfigView.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/29.
//  Copyright © 2019 Svend Jin. All rights reserved.
//
import Cocoa

class ConfigView: NSView {
    
    var paddingTop: Int {
        return 30
    }
    var paddingLeft: Int {
        return 6
    }
    var gapTop: Int {
        return 10
    }
    var gapLeft: Int {
        return 5
    }
    var labelWidth: Int {
        return 75
    }
    var labelHeight: Int {
        return 20
    }
    
    var viewWidth: Int {
        return Int(self.frame.width)
    }
    
    var viewHeight: Int {
        return Int(self.frame.height)
    }
    
    
    var textFieldX: Int {
        return labelWidth + paddingLeft + gapLeft
    }
    
    
    var textFieldWidth: Int {
        return viewWidth - paddingLeft - textFieldX
    }
    
    var y: Int = 0
    
    // 创建配置界面
    static func createConfigView(parentView: NSView, item: Host) {
        // MARK: 根据当前选择的图床，创建对应的配置界面
        switch item.type {
        case .smms:
            parentView.addSubview(SmmsConfigView(frame: parentView.frame, host: item))
            break
        case .custom:
            parentView.addSubview(CustomConfigView(frame: parentView.frame, host: item))
            break
        case .upyun_USS:
            parentView.addSubview(UpYunConfigView(frame: parentView.frame, host: item))
            break
        case .qiniu_KODO:
            parentView.addSubview(QiniuConfigView(frame: parentView.frame, host: item))
            break
        case .aliyun_OSS:
            parentView.addSubview(AliyunConfigView(frame: parentView.frame, host: item))
            break
        case .tencent_COS:
            parentView.addSubview(TencentConfigView(frame: parentView.frame, host: item))
            break
        case .github:
            parentView.addSubview(GithubConfigView(frame: parentView.frame, host: item))
            break
        case .gitee:
            parentView.addSubview(GiteeConfigView(frame: parentView.frame, host: item))
            break
        case .weibo:
            parentView.addSubview(WeiboConfigView(frame: parentView.frame, host: item))
            break
        case .amazon_S3:
            parentView.addSubview(AmazonS3ConfigView(frame: parentView.frame, host: item))
            break
        case .imgur:
            parentView.addSubview(ImgurConfigView(frame: parentView.frame, host: item))
            break
        case .baidu_BOS:
            parentView.addSubview(BaiduConfigView(frame: parentView.frame, host: item))
            break
//        default:
//            let label = NSTextField(labelWithString: "The file will be uploaded anonymously to".localized + " \(item.name)")
//            label.frame = NSRect(x: (parentView.frame.width - label.frame.width) / 2, y: parentView.frame.height - 50, width: label.frame.width, height: 20)
//            parentView.addSubview(label)
        }
    }
    
    var host: Host!
    
    var data: HostConfig? {
        return self.host.data
    }
    
    var domainField: NSTextField?
    
    var nextKeyViews:[NSView] = [NSView]()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        self.createView()
        
        self.setNextKeyViews()
    }
    
    
    init(frame frameRect: NSRect, host: Host) {
        super.init(frame: frameRect)
        
        self.host = host
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView() {
        // Subclasses override
        
        // Initialize the y value
        self.y = self.viewHeight - self.paddingTop
    }
    
    
    /// Create domain input
    /// - Parameters:
    ///   - data: The host object being edited
    ///   - paddingLeft: The distance to the left of the label
    ///   - y: y-axis
    ///   - labelWidth: labelWidth
    ///   - labelHeight: labelHeight
    ///   - textFieldX: textFieldX
    ///   - textFieldWidth: textFieldWidth
    func createDomainField(_ data: HostConfig) {
        let domainLabel = NSTextField(labelWithString: "\(data.displayName(key: "domain")):")
        domainLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        domainLabel.alignment = .right
        domainLabel.lineBreakMode = .byClipping

        let domainField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth, height: labelHeight))
        domainField.identifier = NSUserInterfaceItemIdentifier(rawValue: "domain")
        domainField.usesSingleLineMode = true
        domainField.lineBreakMode = .byTruncatingTail
        domainField.delegate = data
        domainField.stringValue = data.value(forKey: "domain") as? String ?? ""
        domainField.placeholderString = "domain:https://xxx.com".localized
        self.domainField = domainField
        self.addSubview(domainLabel)
        self.addSubview(domainField)
        nextKeyViews.append(domainField)
    }
    
    /// Create save key input
    /// - Parameters:
    ///   - data: The host object being edited
    ///   - paddingLeft: The distance to the left of the label
    ///   - y: y-axis
    ///   - labelWidth: labelWidth
    ///   - labelHeight: labelHeight
    ///   - textFieldX: textFieldX
    ///   - textFieldWidth: textFieldWidth
    func createSaveKeyField(_ data: HostConfig) {
        let saveKeyPathLabel = NSTextField(labelWithString: "\(data.displayName(key: "saveKeyPath")):")
        saveKeyPathLabel.frame = NSRect(x: paddingLeft, y: y, width: labelWidth, height: labelHeight)
        saveKeyPathLabel.alignment = .right
        saveKeyPathLabel.lineBreakMode = .byClipping
        

        let suffixEnable: Bool = data.containsKey(key: "suffix")
        let suffixWidth: Int = suffixEnable ? 40 : 0

        let saveKeyPathField = NSTextField(frame: NSRect(x: textFieldX, y: y, width: textFieldWidth - suffixWidth, height: labelHeight))
        saveKeyPathField.identifier = NSUserInterfaceItemIdentifier(rawValue: "saveKeyPath")
        saveKeyPathField.usesSingleLineMode = true
        saveKeyPathField.lineBreakMode = .byTruncatingTail
        saveKeyPathField.delegate = data
        saveKeyPathField.stringValue = data.value(forKey: "saveKeyPath") as? String ?? BaseUploaderUtil._defaultSaveKeyPath
        saveKeyPathField.placeholderString = "uPic/{filename}{.suffix}"
        self.addSubview(saveKeyPathLabel)
        self.addSubview(saveKeyPathField)
        nextKeyViews.append(saveKeyPathField)
        
        if suffixEnable {
            let suffixField = NSTextField(frame: NSRect(x: textFieldX + textFieldWidth - suffixWidth, y: y, width: suffixWidth, height: labelHeight))
            suffixField.identifier = NSUserInterfaceItemIdentifier(rawValue: "suffix")
            suffixField.usesSingleLineMode = true
            suffixField.lineBreakMode = .byTruncatingTail
            suffixField.delegate = data
            suffixField.stringValue = data.value(forKey: "suffix") as? String ?? ""
            suffixField.placeholderString = "!w"
            suffixField.toolTip = "Suffix Tips".localized
            self.addSubview(suffixField)
            nextKeyViews.append(suffixField)
        }
        
        let saveKeyPathTips = NSTextField(wrappingLabelWithString: "Save Key Tips".localized)
        saveKeyPathTips.frame = NSRect(x: textFieldX, y: y - labelHeight * 3 / 2 - 55, width: textFieldWidth, height: 80)
        saveKeyPathTips.font = NSFont.userFont(ofSize: 12.0)
        saveKeyPathTips.lineBreakMode = .byWordWrapping
        saveKeyPathTips.cell?.wraps = true
        saveKeyPathTips.isSelectable = true
        
        self.addSubview(saveKeyPathTips)
        
    }
    
    
    /// Create help button
    /// - Parameters:
    ///   - paddingRight: Distance to the right
    ///   - y: y-axis
    ///   - url: Help document address
    func createHelpBtn(_ url: String) {
        // help
        let helpBtn = NSButton(title: "", target: self, action: #selector(openTutorial(_:)))
        let helpBtnWidth = Int(helpBtn.frame.width)
        helpBtn.frame = NSRect(x: Int(self.frame.width) - helpBtnWidth - paddingLeft, y: 0, width: helpBtnWidth, height: Int(helpBtn.frame.height))
        helpBtn.title = ""
        helpBtn.bezelStyle = .helpButton
        helpBtn.imagePosition = .imageOnly
        helpBtn.setButtonType(.momentaryPushIn)
        helpBtn.toolTip = url
        self.addSubview(helpBtn)
        
        // testing
        let testBtn = NSButton(title: "Validate".localized, target: self, action: #selector(testUpload(_:)))
        let testBtnWidth = Int(testBtn.frame.width)
        testBtn.frame = NSRect(x: Int(self.frame.width) - testBtnWidth - helpBtnWidth - paddingLeft, y: 0, width: testBtnWidth, height: Int(testBtn.frame.height))
        self.addSubview(testBtn)
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
    
    
    @objc func testUpload(_ sender: NSButton) {
        if let image = NSImage(named: "AppIcon"), let imgData = image.pngData {
            BaseUploader.upload(data: imgData, self.host)
        }
        
    }
}
