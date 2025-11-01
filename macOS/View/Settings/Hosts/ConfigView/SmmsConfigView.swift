//
//  SmmsConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import HandyJSON
import SwiftData
import SwiftUI
import UPicCore

struct SmmsConfigView: View {
    let hostModel: HostModel
    let onSave: () -> Void

    @State private var name: String = HostType.smms.displayNname
    @State private var token: String = ""
    @State private var isTokenSecured: Bool = true

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack {
            Image("host_icon_\(hostModel.typeRaw ?? "")")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)

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
                .frame(height: 30)

                Spacer()

                HStack {
                    Spacer()
                    Button("Save") {
                        saveConfiguration()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || token.isEmpty)
                }
            }
        }
        .padding()
        .onAppear {
            loadConfiguration()
        }
    }

    private func loadConfiguration() {
        if hostModel.dataRaw != nil {
            name = hostModel.name

            if let smmsConfig = hostModel.getConfig(SmmsHostConfig.self) {
                token = smmsConfig.token ?? ""
            }
        }
    }

    private func saveConfiguration() {
        let smmsConfig = SmmsHostConfig()
        smmsConfig.token = token

        hostModel.name = name
        if let jsonString = smmsConfig.toJSONString(), let jsonData = jsonString.data(using: .utf8) {
            hostModel.dataRaw = jsonData
        }

        onSave()
    }
}

#Preview {
    let sampleHostModel = HostModel(.smms, data: nil)
    SmmsConfigView(hostModel: sampleHostModel) {}
        .modelContainer(for: HostModel.self, inMemory: true)
}
