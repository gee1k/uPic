//
//  ImgurConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import HandyJSON
import SwiftData
import SwiftUI
import UPicCore

struct ImgurConfigView: View {
    let hostModel: HostModel
    let onSave: () -> Void

    @State private var name: String = .init(localized: "Imgur")
    @State private var clientId: String = ""
    @State private var isClientIdSecured: Bool = true

    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            // Name
            TextField("Name", text: $name, prompt: Text("Custom name"))
                .frame(height: 30)

            // Client ID
            HStack {
                if isClientIdSecured {
                    SecureField("Client ID", text: $clientId)
                } else {
                    TextField("Client ID", text: $clientId)
                }

                Button {
                    isClientIdSecured.toggle()
                } label: {
                    Image(systemName: isClientIdSecured ? "eye.slash" : "eye")
                        .foregroundStyle(isClientIdSecured ? .primary : Color.blue)
                }
                .buttonStyle(.plain)
                .disabled(clientId.isEmpty)
            }
            .frame(height: 30)

            HStack {
                Spacer()

                // Get Client ID
                Menu {
                    Button("Not created before? Go get one!") {
                        if let url = URL(string: Constants.imgurGetClientIdUrl) {
                            openURL(url)
                        }
                    }

                    Button("Already have one? Go get it!") {
                        if let url = URL(string: Constants.imgurCreateClientIdUrl) {
                            openURL(url)
                        }
                    }
                } label: {
                    Text("Get Client ID")
                        .frame(maxWidth: .infinity)
                }
                .menuIndicator(.hidden)

                // Help button
                Button {
                    if let url = URL(string: Constants.imgurHelpUrl) {
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
                .disabled(name.isEmpty || clientId.isEmpty)
            }
        }
        .padding()
        .onAppear {
            loadConfiguration()
        }
    }

    func loadConfiguration() {
        if hostModel.dataRaw != nil {
            name = hostModel.name

            if let imgurConfig = hostModel.getConfig(ImgurHostConfig.self) {
                clientId = imgurConfig.clientId ?? ""
            }
        }
    }

    func saveConfiguration() {
        let imgurConfig = ImgurHostConfig()
        imgurConfig.clientId = clientId

        hostModel.name = name
        if let jsonString = imgurConfig.toJSONString(), let jsonData = jsonString.data(using: .utf8) {
            hostModel.dataRaw = jsonData
        }

        onSave()
    }
}

#Preview {
    let sampleHostModel = HostModel(.imgur, data: nil)
    ImgurConfigView(hostModel: sampleHostModel) {}
        .modelContainer(for: HostModel.self, inMemory: true)
}
