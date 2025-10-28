//
//  SettingsTabItem.swift
//  uPic
//
//  Created by Licardo on 2025/10/1.
//

import SwiftUI

struct SettingsTabItem: View {
    let title: String
    let systemImage: String
    let tag: Int
    @Binding var selectedTag: Int

    @State private var isHovered = false

    var body: some View {
        Button(action: {
            selectedTag = tag
        }) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text(title)
                    .font(.title3)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .padding(.horizontal, -8)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
        .padding(.vertical, 2)
    }

    private var backgroundColor: Color {
        if selectedTag == tag {
            return Color.accentColor.opacity(0.15)
        } else if isHovered {
            return Color.gray.opacity(0.1)
        } else {
            return Color.clear
        }
    }

    private var foregroundColor: Color {
        if selectedTag == tag {
            return Color.accentColor
        } else {
            return Color.primary
        }
    }
}

#Preview {
    List {
        Section {
            SettingsTabItem(
                title: "General",
                systemImage: "gearshape",
                tag: 0,
                selectedTag: .constant(0)
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)

            SettingsTabItem(
                title: "Actions",
                systemImage: "filemenu.and.selection",
                tag: 1,
                selectedTag: .constant(0)
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)

            SettingsTabItem(
                title: "About",
                systemImage: "info.circle",
                tag: 2,
                selectedTag: .constant(0)
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        } header: {
            VStack(alignment: .leading, spacing: -4) {
                Text("Alright")
                Text("Click")
            }
            .font(.system(size: 32, weight: .medium))
            .foregroundStyle(.primary)
            .padding(.vertical, 5)
        }
    }
    .scrollDisabled(true)
    .navigationSplitViewColumnWidth(180)
}
