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
        // let new = change?[.newKey], 
        if let old = change?[.oldKey] {
            if !(old is NSNull) {
                PreferencesNotifier.postNotification(.hostConfigChanged)
            }
        }
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
            return nil
        case .upyun_USS:
            return UpYunHostConfig()
        case .qiniu_KODO:
            return QiniuHostConfig()
        case .aliyun_OSS:
            return AliyunHostConfig()
        case .tencent_COS:
            return TencentHostConfig()
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
            config = nil
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
        }

        config?.observerValues()
        return config
    }

}

extension HostConfig: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, let key = textField.identifier?.rawValue {

            let value = textField.stringValue
            self.setValue(value, forKey: key)
        }
    }
}
