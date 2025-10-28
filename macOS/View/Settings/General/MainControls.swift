//
//  MainControls.swift
//  AlrightClick
//
//  Created by Licardo on 2025/10/7.
//

import LaunchAtLogin
import SwiftUI

struct MainControls: View {
    var body: some View {
        Section {
            HStack {
                Label("Launch at login", systemImage: "power")
                Spacer()
                LaunchAtLogin.Toggle()
                    .labelsHidden()
                    .toggleStyle(.switch)
            }
        } header: {
            Text("Main Controls")
        }
    }
}

#Preview {
    MainControls()
}
