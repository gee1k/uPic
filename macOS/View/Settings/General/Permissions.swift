//
//  Permissions.swift
//  uPic
//
//  Created by Licardo on 2025/10/7.
//

import Defaults
import SwiftUI

struct Permissions: View {
    @Default(.hasFullDiskAccess) var hasFullDiskAccess

    @State private var isRequestingFullDiskAccessPermission = false
    @State private var showingPermissionAlert = false
    @State private var permissionAlertMessage = ""

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Label("Full disk access", systemImage: "externaldrive")

                    Spacer()

                    if hasFullDiskAccess {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.green)
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
                        }
                    }
                }

                if !hasFullDiskAccess {
                    Text("Required for accessing files on your Mac")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Permissions")
        }
        .onAppear {
            checkPermissions()
        }
        .alert("Disk Access Permission", isPresented: $showingPermissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(permissionAlertMessage)
        }
    }

    // MARK: - 方法

    private func checkPermissions() {
        hasFullDiskAccess = BookmarkManager.shared.checkFullDiskAuthorizationStatus()
    }

    private func requestFullDiskAccess() {
        isRequestingFullDiskAccessPermission = true

        // 在后台线程执行权限请求
        Task {
            await MainActor.run {
                BookmarkManager.shared.requestFullDiskPermissions()

                // 延迟检查权限状态，给系统时间处理
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    checkPermissions()
                    isRequestingFullDiskAccessPermission = false

                    if hasFullDiskAccess {
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
}

#Preview {
    Form {
        Permissions()
    }
    .formStyle(.grouped)
}
