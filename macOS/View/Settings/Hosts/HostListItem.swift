//
//  HostListItem.swift
//  uPic
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import UPicCore

struct HostListItem: View {
    let hostModel: HostModel
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image("host_icon_\(hostModel.typeRaw ?? "smms")")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(hostModel.name)
                        .lineLimit(1)
                        .foregroundColor(foregroundColor)
                    Text(HostType(rawValue: hostModel.typeRaw ?? "")?.displayNname ?? "Unknown")
                        .font(.caption)
                        .foregroundColor(secondaryTextColor)
                }

                Spacer()

                if isHovered {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 20, height: 20)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
            )
            .padding(.horizontal, -8)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .padding(.vertical, 2)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.15)
        } else if isHovered {
            return Color.gray.opacity(0.1)
        } else {
            return Color.clear
        }
    }

    private var foregroundColor: Color {
        if isSelected {
            return Color.accentColor
        } else {
            return Color.primary
        }
    }

    private var secondaryTextColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.7)
        } else {
            return Color.secondary
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        HostListItem(
            hostModel: HostModel(.smms, data: nil),
            isSelected: true,
            onSelect: {},
            onDelete: {}
        )

        HostListItem(
            hostModel: HostModel(.s3, data: nil),
            isSelected: false,
            onSelect: {},
            onDelete: {}
        )
    }
    .listStyle(.plain)
    .frame(width: 200)
    .padding()
}
