//
//  DiskPermissionManager.swift
//  uPic
//
//  Created by Svend Jin on 2021/01/19.
//  Copyright © 2021 Svend Jin. All rights reserved.
//

import Foundation
import Cocoa

public class DiskPermissionManager {
    
    // static
    public static var shared = DiskPermissionManager()
    
    
    private func promptForWorkingDirectoryPermission() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.message = "Authorize".localized
        openPanel.prompt = "Authorize".localized
        openPanel.allowedFileTypes = ["none"]
        openPanel.allowsOtherFileTypes = false
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseDirectories = true
        openPanel.directoryURL = URL(fileURLWithPath: "/", isDirectory: true)

        openPanel.runModal()
        return openPanel.urls.first
    }
    
    private func saveBookmarkData(for workDir: URL) {
        do {
            let bookmarkData = try workDir.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)

            // save in UserDefaults
            Defaults[.workingDirectoryBookmark] = bookmarkData
        } catch {
            print("Failed to save bookmark data for \(workDir)", error)
        }
    }
    
    private func restoreFileAccess(with bookmarkData: Data) -> URL? {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                saveBookmarkData(for: url)
            }
            return url
        } catch {
            print("Error resolving bookmark:", error)
            return nil
        }
    }
    
}

// Utils
extension DiskPermissionManager {
    
    func initializeRequestDiskPermissions() {
        if !Defaults[.requestedAuthorization] {
            Defaults[.requestedAuthorization] = true
            alertInfo(withText: "Full Disk Access".localized, withMessage: "Full Disk Access Message".localized, oKButtonTitle: "Authorize".localized, cancelButtonTitle: "Later".localized){ [self] in
                requestFullDiskPermissions()
            }
        } else {
            guard let data = Defaults[.workingDirectoryBookmark], let url = restoreFileAccess(with: data) else {
                return
            }
            _ = url.startAccessingSecurityScopedResource()
        }
        
    }
    
    func checkFullDiskAuthorizationStatus() -> Bool {
        guard let data = Defaults[.workingDirectoryBookmark] else {
            return false
        }
        do {
            var isStale = true
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            if isStale {
                // bookmarks could become stale as the OS changes
                print("Bookmark is stale, need to save a new one... ")
                return false
            }
            return url.path == "/"
        } catch {
            print("Error resolving bookmark:", error)
            return false
        }
        
        
    }
    
    func requestFullDiskPermissions() {
        guard let url = self.promptForWorkingDirectoryPermission() else {
            return
        }
        self.saveBookmarkData(for: url)
        _ = url.startAccessingSecurityScopedResource()
    }
    
    func stopFullDiskAccessing() {
        guard let data = Defaults[.workingDirectoryBookmark], let url = restoreFileAccess(with: data) else {
            return
        }
        url.stopAccessingSecurityScopedResource()
    }
}
