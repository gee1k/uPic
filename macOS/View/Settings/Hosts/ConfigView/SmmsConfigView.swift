//
//  SmmsConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import SwiftData
import UPicCore
import HandyJSON

struct SmmsConfigView: View {
    let hostModel: HostModel
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var token: String = ""
    @State private var isTokenSecured: Bool = true

    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            // Name
            TextField("Name", text: $name, prompt: Text("Custom name"))
                .frame(height: 30)
            HStack {
                if isTokenSecured {
                    SecureField(text: $token, prompt: Text("SMMS Token")) {
                        Text("Token")
                    }
                } else {
                    TextField(text: $token, prompt: Text("SMMS Token")) {
                        Text("Token")
                    }
                }

                Button {
                    isTokenSecured.toggle()
                } label: {
                    Image(systemName: isTokenSecured ? "eye.slash" : "eye")
                        .foregroundStyle(isTokenSecured ? .primary : Color.blue)
                }
                .buttonStyle(.plain)
                .disabled(token.isEmpty)
            }

            HStack {
                Spacer()

                Button("Get API Token") {
                    if let url = URL(string: Constants.smmsAPITokenUrl) {
                        openURL(url)
                    }
                }

                Button {
                    if let url = URL(string: Constants.smmsHelpUrl) {
                        openURL(url)
                    }
                } label: {
                    Image(systemName: "questionmark")
                        .padding(2)
                }
                .buttonBorderShape(.circle)
            }

            HStack {
                Spacer()
                Button("Save Configuration") {
                    saveConfiguration()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || token.isEmpty)
            }
        }
        .padding()
        .onAppear {
            loadConfiguration()
        }
    }

    private func loadConfiguration() {
        // Load existing data from HostModel
        name = hostModel.name ?? "SMMS"

        if let smmsConfig = hostModel.getConfig(SmmsHostConfig.self) {
            token = smmsConfig.token ?? ""
        }
    }

    private func saveConfiguration() {
        // Create SmmsHostConfig
        let smmsConfig = SmmsHostConfig()
        smmsConfig.token = token

        // Update HostModel
        hostModel.name = name
        if let jsonString = smmsConfig.toJSONString(),
           let jsonData = jsonString.data(using: .utf8) {
            hostModel.dataRaw = jsonData
        }

        do {
            try modelContext.save()
            print("Configuration saved successfully!")
        } catch {
            print("Failed to save configuration: \(error)")
        }
    }
}

#Preview {
    // Create a sample HostModel for preview
    let sampleHostModel = HostModel(.smms, data: nil)
    return SmmsConfigView(hostModel: sampleHostModel)
        .modelContainer(for: HostModel.self, inMemory: true)
}
