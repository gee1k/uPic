//
//  GiteeConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import SwiftData
import UPicCore
import HandyJSON

struct GiteeConfigView: View {
    let hostModel: HostModel
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var userName: String = ""
    @State private var repo: String = ""
    @State private var branch: String = "master"
    @State private var token: String = ""
    @State private var domain: String = ""
    @State private var saveKey: String = "uPic/{filename}{.suffix}"
    @State private var saveKeySuffix: String = ""
    @State private var isTokenSecured: Bool = true

    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            // Name
            TextField("Name", text: $name, prompt: Text("Custom name"))
                .frame(height: 30)

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
                    if let url = URL(string: Constants.giteeHelpUrl) {
                        openURL(url)
                    }
                } label: {
                    Image(systemName: "questionmark")
                        .padding(2)
                }
                .buttonBorderShape(.circle)
            }
        }

        HStack {
            Spacer()
            Button("Save Configuration") {
                saveConfiguration()
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.isEmpty || userName.isEmpty || repo.isEmpty || token.isEmpty)
        }
        .padding()
        .onAppear {
            loadConfiguration()
        }
    }

    private func loadConfiguration() {
        name = hostModel.name ?? "Gitee"

        if let giteeConfig = hostModel.getConfig(GiteeHostConfig.self) {
            userName = giteeConfig.owner ?? ""
            repo = giteeConfig.repo ?? ""
            branch = giteeConfig.branch
            token = giteeConfig.token ?? ""
            domain = giteeConfig.domain
            saveKey = giteeConfig.saveKeyPath ?? "uPic/{filename}{.suffix}"
        }
    }

    private func saveConfiguration() {
        let giteeConfig = GiteeHostConfig()
        giteeConfig.owner = userName
        giteeConfig.repo = repo
        giteeConfig.branch = branch
        giteeConfig.token = token
        giteeConfig.domain = domain
        giteeConfig.saveKeyPath = saveKey

        hostModel.name = name
        if let jsonString = giteeConfig.toJSONString(),
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
    let sampleHostModel = HostModel(.gitee, data: nil)
    return GiteeConfigView(hostModel: sampleHostModel)
        .modelContainer(for: HostModel.self, inMemory: true)
}
