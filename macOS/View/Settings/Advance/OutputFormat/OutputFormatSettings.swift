//
//  OutputFormatSettings.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import Defaults
import SwiftUI

struct OutputFormatSettings: View {
    @Default(.selectedOutputFormat) var selectedOutputFormat
    @Default(.outputFormats) var outputFormats
    @State private var showOutputFormatCustomizeView: Bool = false

    var body: some View {
        Section {
            HStack {
                Label("Output Format", systemImage: "textformat")
                Spacer()
                Picker("", selection: $selectedOutputFormat) {
                    ForEach(outputFormats) { outputFormat in
                        Text(outputFormat.name)
                            .tag(outputFormat)
                    }
                }
                .labelsHidden()

                Button("Config") {
                    showOutputFormatCustomizeView = true
                }
                .sheet(isPresented: $showOutputFormatCustomizeView) {
                    OutputFormatCustomizeView()
                }
            }
        } header: {
            Text("Output Format")
        }
    }
}

#Preview {
    Form {
        OutputFormatSettings()
    }
    .formStyle(.grouped)
}
