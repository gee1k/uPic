//
//  uPicApp.swift
//  uPic
//
//  Created by Licardo on 2025/10/28.
//

import MenuBarExtraAccess
import SimpleLogger
import SwiftData
import SwiftUI
import UPicCore

@main
struct uPicApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject private var uploader = UploadeManager.shared
    private let indicator = NSProgressIndicator()

    var upicModelContainer: ModelContainer = {
        let schema = Schema([
            HostModel.self,
            UploadHistoryModel.self,
        ])

        // 配置iCloud同步并改进错误处理
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            AppLogger.uploader.info("SwiftData ModelContainer with iCloud sync created successfully")
            return container
        } catch {
            // 如果iCloud同步失败，则回退到本地存储
            AppLogger.uploader.error("Failed to create CloudKit ModelContainer, falling back to local storage: \(error.localizedDescription)")
            let localConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )
            do {
                let container = try ModelContainer(for: schema, configurations: [localConfig])
                AppLogger.uploader.info("SwiftData ModelContainer with local storage created successfully")
                return container
            } catch {
                AppLogger.uploader.error("Failed to create local ModelContainer: \(error.localizedDescription)")
                fatalError("Could not create ModelContainer: \(error.localizedDescription)")
            }
        }
    }()

    init() {
        let modelContext = ModelContext(upicModelContainer)
        UploadeManager.shared.configure(with: modelContext)
    }

    var body: some Scene {
        Window("uPic Settings", id: "settings") {
            SettingsView()
                .frame(minWidth: 780, idealWidth: 780, minHeight: 560, idealHeight: 560)
        }
        .modelContainer(upicModelContainer)
        .defaultPosition(.center)
        #if DEBUG
            .defaultLaunchBehavior(.presented)
        #else
            .defaultLaunchBehavior(.suppressed)
        #endif

        Window("uPic Database", id: "database") {
            DatabaseView()
                .frame(minWidth: 780, idealWidth: 780, minHeight: 560, idealHeight: 560)
        }
        .modelContainer(upicModelContainer)
        .defaultPosition(.center)
        .defaultLaunchBehavior(.suppressed)

        MenuBarExtra {
            StatusMenuView()
        } label: {
            Image("statusMenuIcon")
        }
        .modelContainer(upicModelContainer)
        .menuBarExtraAccess(isPresented: .constant(true)) { statusItem in
            statusItem.length = NSStatusItem.squareLength
            setupStatusBarIndicator(statusItem)
        }
    }

    // MARK: - Status Bar Management

    private func setupStatusBarIndicator(_ statusItem: NSStatusItem) {
        guard let button = statusItem.button else { return }

        // 设置进度指示器
        indicator.frame = NSRect(
            x: (button.frame.width - 16) / 2,
            y: (button.frame.height - 16) / 2,
            width: 16,
            height: 16
        )
        indicator.minValue = 0.0
        indicator.maxValue = 1.0
        indicator.isIndeterminate = false
        indicator.controlSize = .small
        indicator.style = .spinning
        indicator.isHidden = true

        indicator.toolTip = String(localized: "Right click to cancel the current upload task")

        button.addSubview(indicator)

        if uploader.isUploading {
            statusItem.button?.image = nil
            indicator.doubleValue = uploader.uploadProgress
            indicator.isHidden = false
        } else {
            let icon = NSImage(named: "statusMenuIcon")
            statusItem.button?.image = icon
            indicator.isHidden = true
            indicator.doubleValue = 0.0
        }
    }
}
