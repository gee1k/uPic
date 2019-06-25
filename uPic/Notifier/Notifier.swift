//
//  Notifier.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/13.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public protocol Notifier {
    associatedtype Notification: RawRepresentable
}

public extension Notifier where Notification.RawValue == String {

    private static func nameFor(notification: Notification) -> String {
        return "\(self).\(notification.rawValue)"
    }


    // instance


    func postNotification(notification: Notification, object: String? = nil) {
        Self.postNotification(notification, object: object)
    }

    func postNotification(notification: Notification, object: String? = nil, userInfo: [String: AnyObject]? = nil) {
        Self.postNotification(notification, object: object, userInfo: userInfo)
    }


    // static

    static func postNotification(_ notification: Notification, object: String? = nil, userInfo: [AnyHashable: Any]? = nil) {
        let name = nameFor(notification: notification)

        DistributedNotificationCenter.default()
                .postNotificationName(NSNotification.Name(rawValue: name), object: object, userInfo: userInfo, deliverImmediately: true)
    }

    // addObserver

    static func addObserver(observer: AnyObject, selector: Selector, notification: Notification, object: String? = nil) {
        let name = nameFor(notification: notification)

        DistributedNotificationCenter.default()
                .addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: name), object: object)
    }

    // removeObserver

    static func removeObserver(observer: AnyObject, notification: Notification, object: String? = nil) {
        let name = nameFor(notification: notification)

        DistributedNotificationCenter.default()
                .removeObserver(observer, name: NSNotification.Name(rawValue: name), object: object)
    }
}
