//
//  ImgurConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import UPicCore

struct ImgurConfigView: View {
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

            // Get Client ID
            HStack {
                Spacer()

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
                .frame(height: 30)
            }

            Spacer()

            // Help Links
            HStack {
                Spacer()
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
        }
        .padding()
    }
}

#Preview {
    ImgurConfigView()
}
