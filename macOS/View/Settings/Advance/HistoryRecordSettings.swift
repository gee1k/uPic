//
//  HistoryRecordSettings.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import Defaults
import SwiftUI

struct HistoryRecordSettings: View {
    @Default(.historyRecordWidth) var historyRecordWidth
    @Default(.historyRecordColumns) var historyRecordColumns
    @Default(.historyRecordSpacing) var historyRecordSpacing
    @Default(.historyRecordPadding) var historyRecordPadding
    @Default(.historyRecordFileNameScrollSpeed) var historyRecordFileNameScrollSpeed
    @Default(.historyRecordFileNameScrollWaitTime) var historyRecordFileNameScrollWaitTime

    var body: some View {
        Section {
            HStack {
                HStack {
                    Text("Width")
                    Spacer()
                    Text("\(historyRecordWidth.formatted()) px")
                    Stepper("", value: $historyRecordWidth, in: 100...500, step: 50)
                        .labelsHidden()
                }

                HStack {
                    Text("Columns")
                    Spacer()
                    Text("\(historyRecordColumns)")
                    Stepper("", value: $historyRecordColumns, in: 3...5, step: 1)
                        .labelsHidden()
                }

                HStack {
                    Text("Spacing")
                    Spacer()
                    Text("\(historyRecordSpacing.formatted()) px")
                    Stepper("", value: $historyRecordSpacing, in: 5...20, step: 5)
                        .labelsHidden()
                }

                HStack {
                    Text("Padding")
                    Spacer()
                    Text("\(historyRecordPadding.formatted()) px")
                    Stepper("", value: $historyRecordPadding, in: 5...20, step: 5)
                        .labelsHidden()
                }
            }

            HStack {
                HStack {
                    Text("Scroll Speed")
                    Spacer()
                    Text("\(historyRecordFileNameScrollSpeed.formatted())")
                    Stepper("", value: $historyRecordFileNameScrollSpeed, in: 10...100, step: 10)
                        .labelsHidden()
                }

                HStack {
                    Text("Scroll Wait Time")
                    Spacer()
                    Text("\(historyRecordFileNameScrollWaitTime.formatted()) s")
                    Stepper("", value: $historyRecordFileNameScrollWaitTime, in: 0.5...10, step: 0.5)
                        .labelsHidden()
                }
            }
            
            HStack {
                Spacer()
                Button("Reset to Default") {
                    Defaults.reset(.historyRecordWidth)
                    Defaults.reset(.historyRecordColumns)
                    Defaults.reset(.historyRecordSpacing)
                    Defaults.reset(.historyRecordPadding)
                    Defaults.reset(.historyRecordFileNameScrollSpeed)
                    Defaults.reset(.historyRecordFileNameScrollWaitTime)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
        } header: {
            Text("History Record")
        }
    }
}

#Preview {
    Form {
        HistoryRecordSettings()
    }
    .formStyle(.grouped)
}
