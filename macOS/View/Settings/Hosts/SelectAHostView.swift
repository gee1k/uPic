//
//  SelectAHostView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/31.
//

import SwiftUI

struct SelectAHostView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "server.rack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Host Selected")
                .font(.title2)

            Text("Select a host from the list")
                .font(.body)
                .padding(.horizontal, 40)
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    SelectAHostView()
        .padding()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {} label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.white, .blue)
                }
                .menuIndicator(.hidden)
            }
        }
}
