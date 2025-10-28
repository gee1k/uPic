//
//  SettingsView.swift
//  uPic
//
//  Created by Licardo on 2025/9/30.
//

import Defaults
import FinderSync
import SwiftUI

struct SettingsView: View {
    @State private var selectedIndex: Int = 0
    @State private var isExtensionEnable: Bool = false

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Image("uPic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    Text("uPic")
                        .font(.title)
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                List {
                    SettingsTabItem(
                        title: String(localized: "General"),
                        systemImage: "gearshape",
                        tag: 0,
                        selectedTag: $selectedIndex
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)

                    SettingsTabItem(
                        title: String(localized: "Advance"),
                        systemImage: "wrench.and.screwdriver",
                        tag: 1,
                        selectedTag: $selectedIndex
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)

                    SettingsTabItem(
                        title: String(localized: "Host"),
                        systemImage: "server.rack", tag: 2,
                        selectedTag: $selectedIndex
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)

                    SettingsTabItem(
                        title: String(localized: "About"),
                        systemImage: "info.circle",
                        tag: 3,
                        selectedTag: $selectedIndex
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
                Spacer()
            }
            .scrollDisabled(true)
            .navigationSplitViewColumnWidth(180)
        } detail: {
            switch selectedIndex {
            case 0:
                GeneralSettingsView()
            case 1:
                AdvanceSettingsView()
            case 2:
                EmptyView()
            case 3:
                AboutSettingsView()
            default:
                GeneralSettingsView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
