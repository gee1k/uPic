//
//  StatusMenuHistorySettings.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/11/1.
//

import Defaults
import SwiftUI

struct StatusMenuHistorySettings: View {
    @Default(.statusMenuHistoryLimit) var statusMenuHistoryLimit

    var body: some View {
        Section {
            HStack {
                Label("Number to display", systemImage: "list.bullet")
                Spacer()

                Text(statusMenuHistoryLimit.formatted())

                Slider(
                    value: Binding(
                        get: { Double(statusMenuHistoryLimit) },
                        set: { statusMenuHistoryLimit = Int($0) }
                    ),
                    in: 5 ... 20,
                    step: 1
                )
                .labelsHidden()
                .frame(width: 200)

                Button {
                    Defaults.reset(.statusMenuHistoryLimit)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("Status Menu History")
        }
    }
}

#Preview {
    Form {
        StatusMenuHistorySettings()
    }
    .formStyle(.grouped)
}
