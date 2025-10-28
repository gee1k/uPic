//
//  GeneralSettingsView.swift
//  AlrightClick
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
        .navigationTitle(Text("General"))
        .formStyle(.grouped)
    }
}

#Preview {
    GeneralSettingsView()
}
