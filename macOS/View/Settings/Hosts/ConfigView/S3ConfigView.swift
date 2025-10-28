//
//  S3ConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import SwiftData
import UPicCore
import HandyJSON
internal import SotoS3

struct S3ConfigView: View {
    let hostModel: HostModel
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var customize: Bool = false
    @State private var region = S3Region.allRegions.first ?? ""
    @State private var endpoint: String = ""
    @State private var bucket: String = ""
    @State private var acl = S3ObjectCannedACL.allCases.first!
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

            // Customize Toggle
            Toggle("Customize", isOn: $customize)
                .toggleStyle(.switch)
                .frame(height: 30)

            // Region or Endpoint based on customize setting
            if customize {
                // Endpoint
                TextField("Endpoint", text: $endpoint)
                    .frame(height: 30)
            } else {
                // Region
                Picker("Region", selection: $region) {
                    ForEach(S3Region.allRegions, id: \.self) { region in
                        Text(region)
                            .tag(region)
                    }
                }
                .frame(height: 30)
            }

            // Bucket
            TextField("Bucket", text: $bucket)
                .frame(height: 30)

            // ACL Control
            Picker("ACL", selection: $acl) {
                ForEach(S3ObjectCannedACL.allCases, id: \.self) { acl in
                    Text(acl.rawValue)
                        .tag(acl)
                }
            }
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
                    if let url = URL(string: Constants.s3HelpUrl) {
                        openURL(url)
                    }
                } label: {
                    Image(systemName: "questionmark")
                        .padding(2)
                }
                .buttonBorderShape(.circle)
            }

            HStack {
                Spacer()
                Button("Save Configuration") {
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

    func loadConfiguration() {
        name = hostModel.name ?? "Amazon S3 Compatible"

        if let s3Config = hostModel.getConfig(S3HostConfig.self) {
            customize = s3Config.customize
            // Find region by matching string value
            if let regionStr = s3Config.region,
               S3Region.allRegions.contains(regionStr) {
                region = regionStr
            }
            endpoint = s3Config.endpoint ?? ""
            bucket = s3Config.bucket ?? ""
            if let aclStr = s3Config.acl,
               let matchedACL = S3ObjectCannedACL.allCases.first(where: { $0.rawValue == aclStr }) {
                acl = matchedACL
            }
            accessKey = s3Config.accessKey ?? ""
            secretKey = s3Config.secretKey ?? ""
            domain = s3Config.domain
            saveKey = s3Config.saveKeyPath ?? "uPic/{filename}{.suffix}"
        }
    }

    func saveConfiguration() {
        let s3Config = S3HostConfig()
        s3Config.customize = customize
        s3Config.region = customize ? nil : region
        s3Config.endpoint = customize ? endpoint : nil
        s3Config.bucket = bucket
        s3Config.acl = acl.rawValue
        s3Config.accessKey = accessKey
        s3Config.secretKey = secretKey
        s3Config.domain = domain
        s3Config.saveKeyPath = saveKey

        hostModel.name = name
        if let jsonString = s3Config.toJSONString(),
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
    let sampleHostModel = HostModel(.s3, data: nil)
    return S3ConfigView(hostModel: sampleHostModel)
        .modelContainer(for: HostModel.self, inMemory: true)
}
