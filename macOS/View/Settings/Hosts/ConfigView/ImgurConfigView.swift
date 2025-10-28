//
//  ImgurConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import UPicCore

struct ImgurConfigView: View {
    @State private var clientId: String = ""
    @State private var isClientIdSecured: Bool = true

    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
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
                        if let url = URL(string: "https://blog.svend.cc/upic/tutorials/imgur") {
                            openURL(url)
                        }
                    }

                    Button("Already have one? Go get it!") {
                        if let url = URL(string: "https://imgur.com/account/settings/apps") {
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
                    if let url = URL(string: "https://blog.svend.cc/upic/tutorials/imgur") {
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
