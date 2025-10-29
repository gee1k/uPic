//
//  Permissions.swift
//  uPic
//
//  Created by Licardo on 2025/10/7.
//

import SwiftUI

struct Permissions: View {
    @State private var hasFullDiskAccessPermission = false
    @State private var isRequestingFullDiskAccessPermission = false
    @State private var showingPermissionAlert = false
    @State private var permissionAlertMessage = ""

    // 使用 DiskPermissionManager 单例
    private let diskPermissionManager = BookmarkManager.shared

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // 完全磁盘访问权限
                diskAccessPermissionView

                // 系统偏好设置快捷方式
                systemPreferencesShortcut
            }
        } header: {
            Text("Permissions")
        }
        .onAppear {
            checkPermissions()
        }
        .alert("Disk Access Permission", isPresented: $showingPermissionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(permissionAlertMessage)
        }
    }

    // MARK: - 子视图

    private var diskAccessPermissionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Full disk access", systemImage: "externaldrive")

                Spacer()

                if hasFullDiskAccessPermission {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.green)
                } else {
                    HStack(spacing: 8) {
                        Button {
                            requestFullDiskAccess()
                        } label: {
                            if isRequestingFullDiskAccessPermission {
                                ProgressView()
                                    .scaleEffect(0.5)
                                    .frame(width: 20, height: 20)
                            } else {
                                Text("Request")
                                    .frame(height: 20)
                            }
                        }
                        .disabled(isRequestingFullDiskAccessPermission)

                        Button("System Settings") {
                            openSystemPreferences()
                        }
                        .frame(height: 20)
                    }
                }
            }

            if !hasFullDiskAccessPermission {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Required for accessing files anywhere on your Mac")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Click 'Request' to authorize file access, or 'System Settings' to configure manually")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("File access permission granted")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }

    private var systemPreferencesShortcut: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Manual configuration", systemImage: "gear")

                Spacer()

                Button("Open System Settings") {
                    openSystemPreferences()
                }
                .frame(height: 20)
            }

            Text("Navigate to Privacy & Security → Full Disk Access")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - 方法

    private func checkPermissions() {
        hasFullDiskAccessPermission = diskPermissionManager.checkFullDiskAuthorizationStatus()
    }

    private func requestFullDiskAccess() {
        isRequestingFullDiskAccessPermission = true

        // 在后台线程执行权限请求
        Task {
            await MainActor.run {
                diskPermissionManager.requestFullDiskPermissions()

                // 延迟检查权限状态，给系统时间处理
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    checkPermissions()
                    isRequestingFullDiskAccessPermission = false

                    if hasFullDiskAccessPermission {
                        permissionAlertMessage = "Full disk access permission granted successfully!"
                        showingPermissionAlert = true
                    } else {
                        permissionAlertMessage = "Permission request completed. If access is still denied, please use 'System Settings' button to configure manually."
                        showingPermissionAlert = true
                    }
                }
            }
        }
    }

    private func openSystemPreferences() {
        diskPermissionManager.openPreferences()
    }
}

#Preview {
    Permissions()
}
