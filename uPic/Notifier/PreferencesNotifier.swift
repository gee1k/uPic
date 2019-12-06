//
//  PreferencesNotifier.swift
//  uPic
//
//  Created by Svend Jin on 2019/6/19.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation

public class PreferencesNotifier: Notifier {

    public enum Notification: String {
        case openConfigSheet
        case saveCustomExtensionSettings
        case hostConfigChanged
        case githubCDNAutoComplete
    }

}
