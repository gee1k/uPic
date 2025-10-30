//
//  GeneralSettingsView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/9/30.
//

import SwiftUI

struct GeneralSettingsView: View {
    var body: some View {
        Form {
            MainControls()

            Permissions()

            SettingsManagement()
        }
        .navigationTitle("General")
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettingsView()
}
