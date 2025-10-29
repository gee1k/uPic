//
//  BaiduConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import HandyJSON
import SwiftData
import SwiftUI
import UPicCore

struct BaiduConfigView: View {
    let hostModel: HostModel
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = .init(localized: "Baidu Cloud BOS")
    @State private var region = BaiduRegion.allRegions.first!
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
                ForEach(BaiduRegion.allRegions, id: \.self) { region in
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
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, maxHeight: 80, alignment: .topLeading)

            Spacer()

            // Help Links
            HStack {
                Spacer()
                Button {
                    if let url = URL(string: Constants.baiduHelpUrl) {
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
                .disabled(name.isEmpty || bucket.isEmpty || accessKey.isEmpty || secretKey.isEmpty)
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

            if let baiduConfig = hostModel.getConfig(BaiduHostConfig.self) {
                bucket = baiduConfig.bucket ?? ""
                accessKey = baiduConfig.accessKey ?? ""
                secretKey = baiduConfig.secretKey ?? ""
                domain = baiduConfig.domain
                saveKey = baiduConfig.saveKeyPath ?? "uPic/{filename}{.suffix}"

                if let regionStr = baiduConfig.region, BaiduRegion.allRegions.contains(regionStr) {
                    region = regionStr
                }
            }
        }
    }

    private func saveConfiguration() {
        let baiduConfig = BaiduHostConfig()
        baiduConfig.bucket = bucket
        baiduConfig.accessKey = accessKey
        baiduConfig.secretKey = secretKey
        baiduConfig.domain = domain
        baiduConfig.saveKeyPath = saveKey
        baiduConfig.region = region

        hostModel.name = name
        if let jsonString = baiduConfig.toJSONString(), let jsonData = jsonString.data(using: .utf8) {
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
    let sampleHostModel = HostModel(.baidu_bos, data: nil)
    return BaiduConfigView(hostModel: sampleHostModel)
        .modelContainer(for: HostModel.self, inMemory: true)
}
