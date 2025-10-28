//
//  GithubConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import UPicCore

struct GithubConfigView: View {
    @State private var userName: String = ""
    @State private var repo: String = ""
    @State private var branch: String = "main"
    @State private var token: String = ""
    @State private var domain: String = ""
    @State private var saveKey: String = "uPic/{filename}{.suffix}"
    @State private var saveKeySuffix: String = ""
    @State private var isTokenSecured: Bool = true

    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            // User Name
            TextField("User Name", text: $userName)
                .frame(height: 30)

            // Repo
            TextField("Repo", text: $repo)
                .frame(height: 30)

            // Branch
            TextField("Branch", text: $branch)
                .frame(height: 30)

            // Token
            HStack {
                if isTokenSecured {
                    SecureField("Token", text: $token)
                } else {
                    TextField("Token", text: $token)
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
            .frame(height: 30)

            // Domain
            TextField("Domain", text: $domain, prompt: Text("Can be empty, there is a default domain"))
                .frame(height: 30)

            // Save Key Path
            HStack {
                TextField("Save Key", text: $saveKey)
                    .fontDesign(.monospaced)
                TextField("", text: $saveKeySuffix, prompt: Text("!w"))
                    .labelsHidden()
                    .frame(minWidth: 40)
                    .fixedSize()
                    .fontDesign(.monospaced)
                    .help("The suffix added during the visit does not affect the upload(also supports variables). Can be used as object storage for image processing styles, etc ... For example: !w means get a watermarked image.")
            }
            .frame(height: 30)

            Text("""
            Supports {year} {month} {day} {hour} {minute} {second} {since_second} {since_millisecond} {random} {filename} {.suffix} {suffix} {mimetype} and etc. For example, the uploaded file is uPic.jpg, set to "uPic/{filename}{.suffix}", it will be saved as: uPic/uPic.jpg.
            """)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxHeight: .infinity, alignment: .topLeading)

            // Help Links
            HStack {
                Spacer()
                Button {
                    if let url = URL(string: "https://blog.svend.cc/upic/tutorials/github") {
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
    GithubConfigView()
}
