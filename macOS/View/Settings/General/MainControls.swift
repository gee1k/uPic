//
//  MainControls.swift
//  AlrightClick
//
//  Created by Licardo on 2025/10/7.
//

import Defaults
import LaunchAtLogin
import SwiftUI

struct MainControls: View {
    var body: some View {
        Section {
            LaunchAtLogin.Toggle {
                Label("Launch at login", systemImage: "power")
                
                Text("uPic will automatically launch at login.")
                    .foregroundStyle(.secondary)
            }
            
            Defaults.Toggle(key: .sendNotification) {
                Label("Notification", systemImage: "bell.badge")
                
                Text("Send notification after uploading.")
                    .foregroundStyle(.secondary)
            }
            
            Defaults.Toggle(key: .sendNotification) {
                Label("Auto clipboard", systemImage: "clipboard")
                
                Text("Copy URL to clipboard automatically after a successful upload.")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Main Controls")
        }
    }
}

#Preview {
    Form {
        MainControls()
    }
    .formStyle(.grouped)
}
