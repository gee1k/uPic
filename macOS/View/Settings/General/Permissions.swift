//
//  Permissions.swift
//  AlrightClick
//
//  Created by Licardo on 2025/10/7.
//

import SwiftUI

struct Permissions: View {
    @State private var hasFullDiskAccessPermission = false
    @State private var isRequestingFullDiskAccessPermission = false

    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    Label("Full disk access", systemImage: "externaldrive")

                    Spacer()

                    if hasFullDiskAccessPermission {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.green)
                    } else {
                        Button {
                            print("磁盘访问授权")
                        } label: {
                            if isRequestingFullDiskAccessPermission {
                                ProgressView()
                                    .scaleEffect(0.5)
                                    .frame(width: 20, height: 20)
                            } else {
                                Text("Request full disk access")
                                    .frame(height: 20)
                            }
                        }
                    }
                }

                if !hasFullDiskAccessPermission {
                    Text("Required for Finder extension to access files and folders")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("Permissions")
        }
    }
}

#Preview {
    Permissions()
}
