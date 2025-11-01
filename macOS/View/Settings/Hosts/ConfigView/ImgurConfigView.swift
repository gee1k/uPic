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
    let onCancel: () -> Void
    let onValidate: () -> Void

    @State private var name: String = HostType.imgur.displayNname
    @State private var clientId: String = ""
    @State private var isClientIdSecured: Bool = true

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
            }

            Spacer()

            HStack {
                Button("Validate") {
                    saveConfiguration()
                    onValidate()
                }
                .disabled(name.isEmpty || clientId.isEmpty)

                Spacer()

                Button("Cancel") {
                    withAnimation {
                        onCancel()
                    }
                }
                .foregroundStyle(.red)

                Button("Save") {
                    withAnimation {
                        saveConfiguration()
                    }
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
    }
}

#Preview {
    let sampleHostModel = HostModel(.imgur, data: nil)
    ImgurConfigView(hostModel: sampleHostModel) {} onCancel: {} onValidate: {}
        .modelContainer(for: HostModel.self, inMemory: true)
}
