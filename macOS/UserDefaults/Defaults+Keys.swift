//
//  Defaults+Keys.swift
//  uPic
//
//  Created by Licardo on 2025/10/1.
//

import Defaults
import Foundation

// Configure App Group UserDefaults
private let appGroupDefaults = UserDefaults(suiteName: "group.com.svend.uPic")!

extension Defaults.Keys {
    // uPic specific keys
    static let firstUsage = Defaults.Key<Bool>("firstUsage", default: true, suite: appGroupDefaults)
    static let defaultHostId = Defaults.Key<String?>("defaultHostId", suite: appGroupDefaults)
    static let selectedOutputFormat = Defaults.Key<OutputFormatModel>("selectedOutputFormatId", default: OutputFormatModel.getDefaultOutputFormats().first!, suite: appGroupDefaults)
    static let outputFormats = Defaults.Key<[OutputFormatModel]>("outputFormats", default: OutputFormatModel.getDefaultOutputFormats(), suite: appGroupDefaults)
    static let outputFormatEncoded = Defaults.Key<Bool>("outputFormatEncoded", default: false, suite: appGroupDefaults)
    static let historyLimit = Defaults.Key<Int>("historyLimit", default: 100, suite: appGroupDefaults)
    static let compressFactor = Defaults.Key<Int>("compressFactor", default: 80, suite: appGroupDefaults)
    static let screenshotApp = Defaults.Key<ScreenshotApp>("screenshotApp", default: .system, suite: appGroupDefaults)
    static let isUploading = Defaults.Key<Bool>("isUploading", default: false, suite: appGroupDefaults)

    // History record settings
    static let historyRecordWidth = Defaults.Key<Float>("historyRecordWidth", default: 200.0, suite: appGroupDefaults)
    static let historyRecordColumns = Defaults.Key<Int>("historyRecordColumns", default: 3, suite: appGroupDefaults)
    static let historyRecordSpacing = Defaults.Key<Float>("historyRecordSpacing", default: 10.0, suite: appGroupDefaults)
    static let historyRecordPadding = Defaults.Key<Float>("historyRecordPadding", default: 5.0, suite: appGroupDefaults)
    static let historyRecordFileNameScrollSpeed = Defaults.Key<Double>("historyRecordFileNameScrollSpeed", default: 50.0, suite: appGroupDefaults)
    static let historyRecordFileNameScrollWaitTime = Defaults.Key<Float>("historyRecordFileNameScrollWaitTime", default: 2.0, suite: appGroupDefaults)

    // Authorization and bookmarks
    static let requestedAuthorization = Defaults.Key<Bool>("requestedAuthorization", default: false, suite: appGroupDefaults)
    static let rootDirectoryBookmark = Defaults.Key<Data?>("rootDirectoryBookmark", suite: appGroupDefaults)
    static let homeDirectoryBookmark = Defaults.Key<Data?>("homeDirectoryBookmark", suite: appGroupDefaults)
    static let rootSubdirectoryBookmarks = Defaults.Key<[Data]>("rootSubdirectoryBookmarks", default: [], suite: appGroupDefaults)
    static let rootSubdirectoryNames = Defaults.Key<[String]>("rootSubdirectoryNames", default: [], suite: appGroupDefaults)
}

enum ScreenshotApp: String, Defaults.Serializable {
    case system
    case longshot

    var displayName: String {
        switch self {
        case .system: return String(localized: "System")
        case .longshot: return String(localized: "Longshot")
        }
    }
}
