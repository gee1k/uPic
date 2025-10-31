//
//  WeiboConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import HandyJSON
import SwiftData
import SwiftUI
import UPicCore

struct WeiboConfigView: View {
    let hostModel: HostModel
    let onSave: () -> Void

    @State private var name: String = HostType.weibo.displayNname
    @State private var cookieMode: Bool = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var cookie: String = ""
    @State private var quality: WeiboqQuality = .large
    @State private var domain: String = "https://tva1.sinaimg.cn"
    @State private var isPasswordSecured: Bool = true

    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            // Name
            TextField("Name", text: $name, prompt: Text("Custom name"))
                .frame(height: 30)

            // Cookie Mode Toggle
            Toggle("Cookie Mode", isOn: $cookieMode)
                .toggleStyle(.switch)
                .frame(height: 30)

            // Username and Password (when not in cookie mode)
            if !cookieMode {
                // Username
                TextField("Username", text: $username)
                    .frame(height: 30)

                // Password
                HStack {
                    if isPasswordSecured {
                        SecureField("Password", text: $password)
                    } else {
                        TextField("Password", text: $password)
                    }

                    Button {
                        isPasswordSecured.toggle()
                    } label: {
                        Image(systemName: isPasswordSecured ? "eye.slash" : "eye")
                            .foregroundStyle(isPasswordSecured ? .primary : Color.blue)
                    }
                    .buttonStyle(.plain)
                    .disabled(password.isEmpty)
                }
                .frame(height: 30)
            }

            // Cookie (when in cookie mode)
            if cookieMode {
                TextField("Cookie", text: $cookie)
                    .frame(height: 30)
            }

            // Quality
            Picker("Quality", selection: $quality) {
                ForEach(WeiboqQuality.allCases, id: \.self) { quality in
                    Text(quality.displayName)
                        .tag(quality)
                }
            }
            .frame(height: 30)

            // Domain
            TextField("Domain", text: $domain, prompt: Text(verbatim: "https://tva1.sinaimg.cn"))
                .frame(height: 30)

            Spacer()

            // Help Links
            HStack {
                Spacer()
                Button {
                    if let url = URL(string: Constants.weiboHelpUrl) {
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
                .disabled(name.isEmpty || (cookieMode ? cookie.isEmpty : (username.isEmpty || password.isEmpty)))
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

            if let weiboConfig = hostModel.getConfig(WeiboHostConfig.self) {
                cookieMode = weiboConfig.cookieMode
                username = weiboConfig.username ?? ""
                password = weiboConfig.password ?? ""
                cookie = weiboConfig.cookie ?? ""
                domain = weiboConfig.domain
                quality = weiboConfig.quality
            }
        }
    }

    private func saveConfiguration() {
        let weiboConfig = WeiboHostConfig()
        weiboConfig.cookieMode = cookieMode
        weiboConfig.username = username
        weiboConfig.password = password
        weiboConfig.cookie = cookie
        weiboConfig.domain = domain
        weiboConfig.quality = quality

        hostModel.name = name
        if let jsonString = weiboConfig.toJSONString(), let jsonData = jsonString.data(using: .utf8) {
            hostModel.dataRaw = jsonData
        }

        onSave()
    }
}

#Preview {
    let sampleHostModel = HostModel(.weibo, data: nil)
    WeiboConfigView(hostModel: sampleHostModel) {}
        .modelContainer(for: HostModel.self, inMemory: true)
}
