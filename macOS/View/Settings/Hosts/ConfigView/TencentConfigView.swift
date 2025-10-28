//
//  TencentConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import UPicCore

struct TencentConfigView: View {
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
                    if let url = URL(string: "https://blog.svend.cc/upic/tutorials/tencent_cos") {
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
    TencentConfigView()
}