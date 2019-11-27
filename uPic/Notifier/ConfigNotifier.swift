//
//  ConfigNotifer.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/14.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class ConfigNotifier: Notifier {

    public enum Notification: String {
        case changeHostItems
        case changeHistoryList
        case updateHistoryList
    }

}
