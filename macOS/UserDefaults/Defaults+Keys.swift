//
//  Defaults+Keys.swift
//  uPic
//
//  Created by Licardo on 2025/10/1.
//

import Defaults
import Foundation

// Configure App Group UserDefaults
private let appGroup = UserDefaults(suiteName: Constants.appGroupIdentifier)!

extension Defaults.Keys {
    // uPic specific keys
    static let firstUsage = Defaults.Key<Bool>("firstUsage", default: true, suite: appGroup)
    static let defaultHostId = Defaults.Key<String?>("defaultHostId", suite: appGroup)
    static let selectedOutputFormat = Defaults.Key<OutputFormatModel>("selectedOutputFormatId", default: OutputFormatModel.getDefaultOutputFormats().first!, suite: appGroup)
    static let outputFormats = Defaults.Key<[OutputFormatModel]>("outputFormats", default: OutputFormatModel.getDefaultOutputFormats(), suite: appGroup)
    static let outputFormatEncoded = Defaults.Key<Bool>("outputFormatEncoded", default: false, suite: appGroup)
    static let historyLimit = Defaults.Key<Int>("historyLimit", default: 100, suite: appGroup)
    static let compressFactor = Defaults.Key<Int>("compressFactor", default: 80, suite: appGroup)
    static let screenshotApp = Defaults.Key<ScreenshotApp>("screenshotApp", default: .system, suite: appGroup)
    static let isUploading = Defaults.Key<Bool>("isUploading", default: false, suite: appGroup)

    // History record settings
    static let historyRecordWidth = Defaults.Key<Float>("historyRecordWidth", default: 200.0, suite: appGroup)
    static let historyRecordColumns = Defaults.Key<Int>("historyRecordColumns", default: 3, suite: appGroup)
    static let historyRecordSpacing = Defaults.Key<Float>("historyRecordSpacing", default: 10.0, suite: appGroup)
    static let historyRecordPadding = Defaults.Key<Float>("historyRecordPadding", default: 5.0, suite: appGroup)
    static let historyRecordFileNameScrollSpeed = Defaults.Key<Double>("historyRecordFileNameScrollSpeed", default: 50.0, suite: appGroup)
    static let historyRecordFileNameScrollWaitTime = Defaults.Key<Float>("historyRecordFileNameScrollWaitTime", default: 2.0, suite: appGroup)

    // Authorization and bookmarks
    static let requestedAuthorization = Defaults.Key<Bool>("requestedAuthorization", default: false, suite: appGroup)
    static let rootDirectoryBookmark = Defaults.Key<Data?>("rootDirectoryBookmark", suite: appGroup)
    static let homeDirectoryBookmark = Defaults.Key<Data?>("homeDirectoryBookmark", suite: appGroup)
    static let rootSubdirectoryBookmarks = Defaults.Key<[Data]>("rootSubdirectoryBookmarks", default: [], suite: appGroup)
    static let rootSubdirectoryNames = Defaults.Key<[String]>("rootSubdirectoryNames", default: [], suite: appGroup)
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
