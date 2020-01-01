//
//  HostConfig.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/15.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
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
        case .upyun_USS:
            return UpYunHostConfig()
        case .qiniu_KODO:
            return QiniuHostConfig()
        case .aliyun_OSS:
            return AliyunHostConfig()
        case .tencent_COS:
            return TencentHostConfig()
        case .github:
            return GithubHostConfig()
        case .gitee:
            return GiteeHostConfig()
        case .weibo:
            return WeiboHostConfig()
        case .amazon_S3:
            return AmazonS3HostConfig()
        case .imgur:
            return ImgurHostConfig()
        case .baidu_BOS:
            return BaiduHostConfig()
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
        case .upyun_USS:
            config = UpYunHostConfig.deserialize(str: str)
            break
        case .qiniu_KODO:
            config = QiniuHostConfig.deserialize(str: str)
            break
        case .aliyun_OSS:
            config = AliyunHostConfig.deserialize(str: str)
            break
        case .tencent_COS:
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
        case .amazon_S3:
            config = AmazonS3HostConfig.deserialize(str: str)
            break
        case .imgur:
            config = ImgurHostConfig.deserialize(str: str)
            break
        case .baidu_BOS:
            config = BaiduHostConfig.deserialize(str: str)
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
            var saveKeyPath = self.value(forKey: "saveKeyPath") as! String
            if saveKeyPath.hasPrefix("/") {
                saveKeyPath.removeFirst()
                self.setValue(saveKeyPath, forKey: "saveKeyPath")
            }
        }
        
        if self.containsKey(key: "domain") {
            var domain = self.value(forKey: "domain") as! String
            if domain.hasSuffix("/") {
                domain.removeLast()
                self.setValue(domain, forKey: "domain")
            }
            
            if (!domain.isEmpty && !domain.hasPrefix("http://") && !domain.hasPrefix("https://")) {
                domain = "http://\(domain)"
                self.setValue(domain, forKey: "domain")
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
