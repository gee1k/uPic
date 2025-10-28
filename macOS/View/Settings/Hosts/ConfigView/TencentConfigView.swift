//
//  TencentConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import SwiftData
import UPicCore
import HandyJSON

struct TencentConfigView: View {
    let hostModel: HostModel
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var region = TencentRegion.allRegions.first!
    @State private var bucket: String = ""
    @State private var secretId: String = ""
    @State private var secretKey: String = ""
    @State private var domain: String = ""
    @State private var saveKey: String = "uPic/{filename}{.suffix}"
    @State private var saveKeySuffix: String = ""
    @State private var isSecretIdSecured: Bool = true
    @State private var isSecretKeySecured: Bool = true

    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            // Name
            TextField("Name", text: $name, prompt: Text("Custom name"))
                .frame(height: 30)

            // Region
            Picker("Region", selection: $region) {
                ForEach(TencentRegion.allRegions, id: \.self) { region in
                    Text(region)
                        .tag(region)
                }
            }
            .frame(height: 30)

            // Bucket
            TextField("Bucket", text: $bucket)
                .frame(height: 30)

            // Secret Id
            HStack {
                if isSecretIdSecured {
                    SecureField("Secret Id", text: $secretId)
                } else {
                    TextField("Secret Id", text: $secretId)
                }

                Button {
                    isSecretIdSecured.toggle()
                } label: {
                    Image(systemName: isSecretIdSecured ? "eye.slash" : "eye")
                        .foregroundStyle(isSecretIdSecured ? .primary : Color.blue)
                }
                .buttonStyle(.plain)
                .disabled(secretId.isEmpty)
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
                    if let url = URL(string: Constants.tencentHelpUrl) {
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
            .disabled(name.isEmpty || bucket.isEmpty || secretId.isEmpty || secretKey.isEmpty)
        }
        .padding()
        .onAppear {
            loadConfiguration()
        }
    }

    private func loadConfiguration() {
        name = hostModel.name ?? "Tencent Cloud COS"

        if let tencentConfig = hostModel.getConfig(TencentHostConfig.self) {
            bucket = tencentConfig.bucket ?? ""
            secretId = tencentConfig.secretId ?? ""
            secretKey = tencentConfig.secretKey ?? ""
            domain = tencentConfig.domain
            saveKey = tencentConfig.saveKeyPath ?? "uPic/{filename}{.suffix}"

            // Find region by matching string value
            if let regionStr = tencentConfig.region,
               TencentRegion.allRegions.contains(regionStr) {
                region = regionStr
            }
        }
    }

    private func saveConfiguration() {
        let tencentConfig = TencentHostConfig()
        tencentConfig.bucket = bucket
        tencentConfig.secretId = secretId
        tencentConfig.secretKey = secretKey
        tencentConfig.domain = domain
        tencentConfig.saveKeyPath = saveKey
        tencentConfig.region = region

        hostModel.name = name
        if let jsonString = tencentConfig.toJSONString(),
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
    let sampleHostModel = HostModel(.tencent_cos, data: nil)
    return TencentConfigView(hostModel: sampleHostModel)
        .modelContainer(for: HostModel.self, inMemory: true)
}
