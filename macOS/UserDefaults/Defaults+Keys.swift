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
    static let firstUsage = Defaults.Key<Bool>("firstUsage", default: true, suite: appGroupUserDefaults, iCloud: true)
    static let selectedHostId = Defaults.Key<String?>("selectedHostId", suite: appGroupUserDefaults, iCloud: true)
    static let selectedOutputFormat = Defaults.Key<OutputFormatModel>("selectedOutputFormat", default: OutputFormatModel.getDefaultOutputFormats().first!, suite: appGroupUserDefaults, iCloud: true)
    static let outputFormats = Defaults.Key<[OutputFormatModel]>("outputFormats", default: OutputFormatModel.getDefaultOutputFormats(), suite: appGroupUserDefaults, iCloud: true)
    static let outputFormatEncoded = Defaults.Key<Bool>("outputFormatEncoded", default: false, suite: appGroupUserDefaults, iCloud: true)
    static let statusMenuHistoryLimit = Defaults.Key<Int>("statusMenuHistoryLimit", default: 10, suite: appGroupUserDefaults, iCloud: true)
    static let compressFactor = Defaults.Key<Int>("compressFactor", default: 20, suite: appGroupUserDefaults, iCloud: true)
    static let screenshotApp = Defaults.Key<ScreenshotApp>("screenshotApp", default: .system, suite: appGroupUserDefaults, iCloud: true)
    static let customScreenshotAppUlrScheme = Defaults.Key<String>("customScreenshotAppUlrScheme", default: "", suite: appGroupUserDefaults, iCloud: true)
    static let autoCopyUrlToClipboard = Defaults.Key<Bool>("autoCopyUrlToClipboard", default: true, suite: appGroupUserDefaults, iCloud: true)
    static let sendNotification = Defaults.Key<Bool>("sendNotification", default: true, suite: appGroupUserDefaults, iCloud: true)

    // Authorization and bookmarks
    // Note: Bookmark data should not sync to iCloud as they contain system-specific security-scoped bookmarks
    static let hasFullDiskAccess = Defaults.Key<Bool>("hasFullDiskAccess", default: false, suite: appGroupUserDefaults)
    static let rootDirectoryBookmark = Defaults.Key<Data?>("rootDirectoryBookmark", suite: appGroupUserDefaults)
    static let homeDirectoryBookmark = Defaults.Key<Data?>("homeDirectoryBookmark", suite: appGroupUserDefaults)
    static let rootSubdirectoryBookmarks = Defaults.Key<[Data]?>("rootSubdirectoryBookmarks", suite: appGroupUserDefaults)
    static let rootSubdirectoryNames = Defaults.Key<[String]?>("rootSubdirectoryNames", suite: appGroupUserDefaults)
}

enum ScreenshotApp: String, CaseIterable, Defaults.Serializable {
    case system
    case longshot
    case x_callback_url

    var displayName: String {
        switch self {
        case .system: return String(localized: "System")
        case .longshot: return String(localized: "Longshot")
        case .x_callback_url: return "x-callback-url"
        }
    }

    var icon: Image {
        switch self {
        case .system: return Image(systemName: "apple.logo")
        case .longshot: return Image("LongShot")
        case .x_callback_url: return Image(systemName: "link")
        }
    }
}
