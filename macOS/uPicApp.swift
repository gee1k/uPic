//
//  uPicApp.swift
//  uPic
//
//  Created by Licardo on 2025/10/28.
//

import SwiftData
import SwiftUI
import Defaults
import UPicCore

@main
struct uPicApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Default(.isUploading) var isUploading

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            HostModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        Window("uPic Settings", id: "settings") {
            SettingsView()
                .frame(minWidth: 780, idealWidth: 780, minHeight: 560, idealHeight: 560)
        }
        .modelContainer(sharedModelContainer)
        .defaultPosition(.center)
        #if DEBUG
            .defaultLaunchBehavior(.presented)
        #else
            .defaultLaunchBehavior(.suppressed)
        #endif

        MenuBarExtra {
            StatusMenuView()
        } label: {
            Image(isUploading ? "uploadingStatusMenuIcon" : "statusMenuIcon")
        }
        .modelContainer(sharedModelContainer)
    }
}
