//
//  SmmsConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI

struct SmmsConfigView: View {
    @State private var name: String = .init(localized: "SMMS")
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
        }
        .padding()
    }
}

#Preview {
    SmmsConfigView()
}
