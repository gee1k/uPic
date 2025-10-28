//
//  Defaults+Keys.swift
//  uPic
//
//  Created by Licardo on 2025/10/1.
//

import Defaults
import Foundation
import SwiftUI

private let appGroupUserDefaults = UserDefaults(suiteName: Constants.appGroupIdentifier)!

extension Defaults.Keys {
    // uPic specific keys
    static let firstUsage = Defaults.Key<Bool>("firstUsage", default: true, suite: appGroupUserDefaults)
    static let selectedHostId = Defaults.Key<String?>("selectedHostId", suite: appGroupUserDefaults)
    static let selectedHostName = Defaults.Key<String?>("selectedHostName", suite: appGroupUserDefaults)
    static let selectedOutputFormat = Defaults.Key<OutputFormatModel>("selectedOutputFormat", default: OutputFormatModel.getDefaultOutputFormats().first!, suite: appGroupUserDefaults)
    static let outputFormats = Defaults.Key<[OutputFormatModel]>("outputFormats", default: OutputFormatModel.getDefaultOutputFormats(), suite: appGroupUserDefaults)
    static let outputFormatEncoded = Defaults.Key<Bool>("outputFormatEncoded", default: false, suite: appGroupUserDefaults)
    static let historyLimit = Defaults.Key<Int>("historyLimit", default: 100, suite: appGroupUserDefaults)
    static let compressFactor = Defaults.Key<Int>("compressFactor", default: 80, suite: appGroupUserDefaults)
    static let screenshotApp = Defaults.Key<ScreenshotApp>("screenshotApp", default: .system, suite: appGroupUserDefaults)
    static let isUploading = Defaults.Key<Bool>("isUploading", default: false, suite: appGroupUserDefaults)

    // History record settings
    static let historyRecordWidth = Defaults.Key<Float>("historyRecordWidth", default: 200.0, suite: appGroupUserDefaults)
    static let historyRecordColumns = Defaults.Key<Int>("historyRecordColumns", default: 3, suite: appGroupUserDefaults)
    static let historyRecordSpacing = Defaults.Key<Float>("historyRecordSpacing", default: 10.0, suite: appGroupUserDefaults)
    static let historyRecordPadding = Defaults.Key<Float>("historyRecordPadding", default: 5.0, suite: appGroupUserDefaults)
    static let historyRecordFileNameScrollSpeed = Defaults.Key<Double>("historyRecordFileNameScrollSpeed", default: 50.0, suite: appGroupUserDefaults)
    static let historyRecordFileNameScrollWaitTime = Defaults.Key<Float>("historyRecordFileNameScrollWaitTime", default: 2.0, suite: appGroupUserDefaults)

    // Authorization and bookmarks
    static let requestedAuthorization = Defaults.Key<Bool>("requestedAuthorization", default: false, suite: appGroupUserDefaults)
    static let rootDirectoryBookmark = Defaults.Key<Data?>("rootDirectoryBookmark", suite: appGroupUserDefaults)
    static let homeDirectoryBookmark = Defaults.Key<Data?>("homeDirectoryBookmark", suite: appGroupUserDefaults)
    static let rootSubdirectoryBookmarks = Defaults.Key<[Data]>("rootSubdirectoryBookmarks", default: [], suite: appGroupUserDefaults)
    static let rootSubdirectoryNames = Defaults.Key<[String]>("rootSubdirectoryNames", default: [], suite: appGroupUserDefaults)
}

enum ScreenshotApp: String, CaseIterable, Defaults.Serializable {
    case system
    case longshot

    var displayName: String {
        switch self {
        case .system: return String(localized: "System")
        case .longshot: return String(localized: "Longshot")
        }
    }

    var icon: Image {
        switch self {
        case .system: return Image(systemName: "apple.logo")
        case .longshot: return Image("LongShot")
        }
    }
}
