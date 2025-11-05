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
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .scaleEffect(isHovered ? 1.1 : 1.0)

                VStack(alignment: .leading, spacing: 2) {
                    Text(hostModel.name)
                        .lineLimit(1)
                        .foregroundStyle(isSelected ? Color.accentColor : .primary)
                    Text(HostType(rawValue: hostModel.typeRaw ?? "")?.displayNname ?? "Unknown")
                        .font(.caption)
                        .foregroundStyle(isSelected ? Color.accentColor : .primary)
                }

                Spacer()

                if isHovered {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
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
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .padding(.vertical, 2)
    }

    private var backgroundColor: Color {
        if isSelected {
            return .accentColor.opacity(0.15)
        } else if isHovered {
            return .gray.opacity(0.1)
        } else {
            return .clear
        }
    }

    private var foregroundColor: Color {
        if isSelected {
            return .accentColor
        } else {
            return .primary
        }
    }

    private var secondaryTextColor: Color {
        if isSelected {
            return .accentColor.opacity(0.7)
        } else {
            return .secondary
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
