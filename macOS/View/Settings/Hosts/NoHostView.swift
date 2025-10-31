//
//  NoHostView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/31.
//

import SwiftUI

struct NoHostView: View {
    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .bottom, spacing: 0) {
                    Spacer()
                    Text("Add a host here")
                        .font(.footnote)
                        .offset(y: 4)
                    Image(systemName: "arrow.turn.right.up")
                        .font(.system(size: 20))
                }
                Spacer()
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 16)

            VStack(spacing: 20) {
                Image(systemName: "server.rack")
                    .font(.system(size: 48))

                Text("Please add a host first")
                    .font(.title2)
            }
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    NoHostView()
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
