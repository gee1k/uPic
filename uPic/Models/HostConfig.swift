//
//  HostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/15.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa
import SwiftyJSON

@objcMembers
class HostConfig: NSObject, Codable {
    private var addedObserver = false

    //注册监听
    override init() {
        super.init()
    }

    deinit {
        self.removeObserverValues()
    }

    //处理监听
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        PreferencesNotifier.postNotification(.hostConfigChanged)
    }

    func observerValues() {
        if self.addedObserver == true {
            return
        }
        self.addedObserver = true
        let morror = Mirror.init(reflecting: self)
        for (name, _) in (morror.children) {
            addObserver(self, forKeyPath: name!, options: [.new, .old], context: nil)
        }
    }


    func removeObserverValues() {
        if !self.addedObserver {
            return
        }
        self.addedObserver = false
        let morror = Mirror.init(reflecting: self)
        for (name, _) in (morror.children) {
            removeObserver(self, forKeyPath: name!, context: nil)
        }
    }

    // Static

    static func create(type: HostType) -> HostConfig? {
        switch type {
        case .smms:
            return SmmsHostConfig()
        case .custom:
            return CustomHostConfig()
        case .upyun_uss:
            return UpYunHostConfig()
        case .qiniu_kodo:
            return QiniuHostConfig()
        case .aliyun_oss:
            return AliyunHostConfig()
        case .tencent_cos:
            return TencentHostConfig()
        case .github:
            return GithubHostConfig()
        case .gitee:
            return GiteeHostConfig()
        case .weibo:
            return WeiboHostConfig()
        case .s3:
            return S3HostConfig()
        case .imgur:
            return ImgurHostConfig()
        case .baidu_bos:
            return BaiduHostConfig()
        case .lsky_pro:
            return LskyProHostConfig()
        case .coding:
            return CodingHostConfig()
        }
    }

    func displayName(key: String) -> String {
        return ""
    }

    func serialize() -> String {
        return ""
    }

    static func deserialize(type: HostType, str: String?) -> HostConfig? {
        var config: HostConfig?
        switch type {
        case .smms:
            config = SmmsHostConfig.deserialize(str: str)
            break
        case .custom:
            config = CustomHostConfig.deserialize(str: str)
            break
        case .upyun_uss:
            config = UpYunHostConfig.deserialize(str: str)
            break
        case .qiniu_kodo:
            config = QiniuHostConfig.deserialize(str: str)
            break
        case .aliyun_oss:
            config = AliyunHostConfig.deserialize(str: str)
            break
        case .tencent_cos:
            config = TencentHostConfig.deserialize(str: str)
            break
        case .github:
            config = GithubHostConfig.deserialize(str: str)
            break
        case .gitee:
            config = GiteeHostConfig.deserialize(str: str)
            break
        case .weibo:
            config = WeiboHostConfig.deserialize(str: str)
            break
        case .s3:
            config = S3HostConfig.deserialize(str: str)
            break
        case .imgur:
            config = ImgurHostConfig.deserialize(str: str)
            break
        case .baidu_bos:
            config = BaiduHostConfig.deserialize(str: str)
            break
        case .lsky_pro:
            config = LskyProHostConfig.deserialize(str: str)
            break
        case .coding:
            config = CodingHostConfig.deserialize(str: str)
            break
        }
        
        config?.fixPrefixAndSuffix()
        config?.observerValues()
        return config
    }
    
    func containsKey(key: String) -> Bool {
        let morror = Mirror.init(reflecting: self)
        return morror.children.contains(where: {(label, _ ) -> Bool in
            return label == key
        })
    }
    
    // 修复用户有时候会不注意在 domain 后面多写一个 /
    func fixPrefixAndSuffix() {
        if self.containsKey(key: "saveKeyPath") {
            if var saveKeyPath = self.value(forKey: "saveKeyPath") as? String, saveKeyPath.hasPrefix("/") {
                saveKeyPath.removeFirst()
                self.setValue(saveKeyPath, forKey: "saveKeyPath")
            }
        }
    }

}

extension HostConfig: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, let key = textField.identifier?.rawValue {
            let value = textField.stringValue
            let trimValue = value.trim()
            self.setValue(trimValue, forKey: key)
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, let key = textField.identifier?.rawValue {
            textField.stringValue = self.value(forKey: key) as? String ?? textField.stringValue
        }
    }
}
