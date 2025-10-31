//
//  UpyunConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import HandyJSON
import SwiftData
import SwiftUI
import UPicCore

struct UpyunConfigView: View {
    let hostModel: HostModel
    let onSave: () -> Void

    @State private var name: String = HostType.upyun_uss.displayNname
    @State private var bucket: String = ""
    @State private var operatorName: String = ""
    @State private var password: String = ""
    @State private var domain: String = ""
    @State private var saveKey: String = "uPic/{filename}{.suffix}"
    @State private var saveKeySuffix: String = ""
    @State private var isPasswordSecured: Bool = true

    @Environment(\.openURL) private var openURL

    var body: some View {
        Form {
            // Name
            TextField("Name", text: $name, prompt: Text("Custom name"))
                .frame(height: 30)

            // Bucket
            TextField("Bucket", text: $bucket)
                .frame(height: 30)

            // Operator
            TextField("Operator", text: $operatorName, prompt: Text("Operator name"))
                .frame(height: 30)

            // Password
            HStack {
                if isPasswordSecured {
                    SecureField("Password", text: $password, prompt: Text("Operator password"))
                } else {
                    TextField("Password", text: $password, prompt: Text("Operator password"))
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

            // Domain
            TextField("Domain", text: $domain, prompt: Text(verbatim: "https://your-domain.com"))
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
                    if let url = URL(string: Constants.upyunHelpUrl) {
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
                .disabled(name.isEmpty || bucket.isEmpty || operatorName.isEmpty || password.isEmpty)
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

            if let upyunConfig = hostModel.getConfig(UpyunHostConfig.self) {
                bucket = upyunConfig.bucket ?? ""
                operatorName = upyunConfig.operatorName ?? ""
                password = upyunConfig.password ?? ""
                domain = upyunConfig.domain
                saveKey = upyunConfig.saveKeyPath ?? "uPic/{filename}{.suffix}"
            }
        }
    }

    private func saveConfiguration() {
        let upyunConfig = UpyunHostConfig()
        upyunConfig.bucket = bucket
        upyunConfig.operatorName = operatorName
        upyunConfig.password = password
        upyunConfig.domain = domain
        upyunConfig.saveKeyPath = saveKey

        hostModel.name = name
        if let jsonString = upyunConfig.toJSONString(), let jsonData = jsonString.data(using: .utf8) {
            hostModel.dataRaw = jsonData
        }

        onSave()
    }
}

#Preview {
    let sampleHostModel = HostModel(.upyun_uss, data: nil)
    UpyunConfigView(hostModel: sampleHostModel) {}
        .modelContainer(for: HostModel.self, inMemory: true)
}
