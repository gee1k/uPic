//
//  QiniuConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import SwiftData
import UPicCore
import HandyJSON

struct QiniuConfigView: View {
    let hostModel: HostModel
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var region = QiniuRegion.allRegions.first!
    @State private var bucket: String = ""
    @State private var accessKey: String = ""
    @State private var secretKey: String = ""
    @State private var domain: String = ""
    @State private var saveKey: String = "uPic/{filename}{.suffix}"
    @State private var saveKeySuffix: String = ""
    @State private var isAccessKeySecured: Bool = true
    @State private var isSecretKeySecured: Bool = true

    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            // Name
            TextField("Name", text: $name, prompt: Text("Custom name"))
                .frame(height: 30)

            // Region
            Picker("Region", selection: $region) {
                ForEach(QiniuRegion.allRegions, id: \.self) { region in
                    Text(region)
                        .tag(region)
                }
            }
            .frame(height: 30)

            // Bucket
            TextField("Bucket", text: $bucket)
                .frame(height: 30)

            // Access Key
            HStack {
                if isAccessKeySecured {
                    SecureField("Access Key", text: $accessKey)
                } else {
                    TextField("Access Key", text: $accessKey)
                }

                Button {
                    isAccessKeySecured.toggle()
                } label: {
                    Image(systemName: isAccessKeySecured ? "eye.slash" : "eye")
                        .foregroundStyle(isAccessKeySecured ? .primary : Color.blue)
                }
                .buttonStyle(.plain)
                .disabled(accessKey.isEmpty)
            }
            .frame(height: 30)

            // Secret Key
            HStack {
                if isSecretKeySecured {
                    SecureField("Secret Key", text: $secretKey)
                } else {
                    TextField("Secret Key", text: $secretKey)
                }

                Button {
                    isSecretKeySecured.toggle()
                } label: {
                    Image(systemName: isSecretKeySecured ? "eye.slash" : "eye")
                        .foregroundStyle(isSecretKeySecured ? .primary : Color.blue)
                }
                .buttonStyle(.plain)
                .disabled(secretKey.isEmpty)
            }
            .frame(height: 30)

            // Domain
            TextField("Domain", text: $domain, prompt: Text(verbatim: "https://your-domain.com"))
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
                    if let url = URL(string: Constants.qiniuHelpUrl) {
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
            .disabled(name.isEmpty || bucket.isEmpty || accessKey.isEmpty || secretKey.isEmpty)
        }
        .padding()
        .onAppear {
            loadConfiguration()
        }
    }

    private func loadConfiguration() {
        name = hostModel.name ?? "Qiniu KODO"

        if let qiniuConfig = hostModel.getConfig(QiniuHostConfig.self) {
            bucket = qiniuConfig.bucket ?? ""
            accessKey = qiniuConfig.accessKey ?? ""
            secretKey = qiniuConfig.secretKey ?? ""
            domain = qiniuConfig.domain ?? ""
            saveKey = qiniuConfig.saveKeyPath ?? "uPic/{filename}{.suffix}"

            // Find region by matching string value
            if let regionStr = qiniuConfig.region,
               QiniuRegion.allRegions.contains(regionStr) {
                region = regionStr
            }
        }
    }

    private func saveConfiguration() {
        let qiniuConfig = QiniuHostConfig()
        qiniuConfig.bucket = bucket
        qiniuConfig.accessKey = accessKey
        qiniuConfig.secretKey = secretKey
        qiniuConfig.domain = domain
        qiniuConfig.saveKeyPath = saveKey
        qiniuConfig.region = region

        hostModel.name = name
        if let jsonString = qiniuConfig.toJSONString(),
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
    let sampleHostModel = HostModel(.qiniu_kodo, data: nil)
    return QiniuConfigView(hostModel: sampleHostModel)
        .modelContainer(for: HostModel.self, inMemory: true)
}
