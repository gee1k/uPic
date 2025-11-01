//
//  GithubConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import HandyJSON
import SwiftData
import SwiftUI
import UPicCore

struct GithubConfigView: View {
    let hostModel: HostModel
    let onSave: () -> Void

    @State private var name: String = HostType.github.displayNname
    @State private var userName: String = ""
    @State private var repo: String = ""
    @State private var branch: String = "main"
    @State private var token: String = ""
    @State private var domain: String = ""
    @State private var saveKey: String = "uPic/{filename}{.suffix}"
    @State private var saveKeySuffix: String = ""
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
                    TextField("", text: $saveKeySuffix, prompt: Text(verbatim: "!w"))
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
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: 80, alignment: .topLeading)
                
                Spacer()
                
                // Help Links
                HStack {
                    Spacer()
                    Button {
                        if let url = URL(string: Constants.githubHelpUrl) {
                            openURL(url)
                        }
                    } label: {
                        Image(systemName: "questionmark")
                            .padding(2)
                    }
                    .buttonBorderShape(.circle)
                }
                .frame(height: 30)
                
                HStack {
                    Spacer()
                    Button("Save") {
                        saveConfiguration()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || userName.isEmpty || repo.isEmpty || token.isEmpty)
                }
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

            if let githubConfig = hostModel.getConfig(GithubHostConfig.self) {
                userName = githubConfig.owner ?? ""
                repo = githubConfig.repo ?? ""
                branch = githubConfig.branch
                token = githubConfig.token ?? ""
                domain = githubConfig.domain
                saveKey = githubConfig.saveKeyPath ?? "uPic/{filename}{.suffix}"
            }
        }
    }

    func saveConfiguration() {
        let githubConfig = GithubHostConfig()
        githubConfig.owner = userName
        githubConfig.repo = repo
        githubConfig.branch = branch
        githubConfig.token = token
        githubConfig.domain = domain
        githubConfig.saveKeyPath = saveKey

        hostModel.name = name
        if let jsonString = githubConfig.toJSONString(), let jsonData = jsonString.data(using: .utf8) {
            hostModel.dataRaw = jsonData
        }

        onSave()
    }
}

#Preview {
    let sampleHostModel = HostModel(.github, data: nil)
    GithubConfigView(hostModel: sampleHostModel) {}
        .modelContainer(for: HostModel.self, inMemory: true)
}
