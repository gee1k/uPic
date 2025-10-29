//
//  CustomConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import HandyJSON
import SwiftData
import SwiftUI
import UPicCore

struct CustomConfigView: View {
    let hostModel: HostModel
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = .init(localized: "Custom")
    @State private var apiUrl: String = ""
    @State private var method: CustomRequestMethod = .POST
    @State private var fileField: String = ""
    @State private var resultPath: String = ""
    @State private var domain: String = ""
    @State private var saveKey: String = "uPic/{filename}{.suffix}"
    @State private var saveKeySuffix: String = ""
    @State private var useBase64: Bool = false
    @State private var showOtherFieldsSheet: Bool = false
    @State private var headersText: String = ""
    @State private var bodyText: String = ""

    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            // Name
            TextField("Name", text: $name, prompt: Text("Custom name"))
                .frame(height: 30)

            // URL
            TextField("API URL", text: $apiUrl)
                .frame(height: 30)

            // Method and Use Base64
            HStack {
                Picker("Method", selection: $method) {
                    ForEach(CustomRequestMethod.allCases, id: \.self) { method in
                        Text(method.rawValue)
                            .tag(method)
                    }
                }

                Spacer()

                Text("Use Base64")
                Toggle("Use Base64", isOn: $useBase64)
                    .labelsHidden()
            }
            .frame(height: 30)

            // Field with Other Fields button
            HStack {
                TextField("File Field", text: $fileField)
                    .frame(height: 30)

                Button("Other fields") {
                    showOtherFieldsSheet = true
                }
                .frame(width: 100)
            }

            // Result Path
            TextField("Result Path", text: $resultPath, prompt: Text("The path to the URL field in Response JSON"))
                .frame(height: 30)

            // Domain
            TextField("Domain", text: $domain, prompt: Text("(optional), When filled, URL = domain + URL path value"))
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
                    if let url = URL(string: Constants.customHelpUrl) {
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
            .disabled(name.isEmpty || apiUrl.isEmpty)
        }
        .padding()
        .onAppear {
            loadConfiguration()
        }
        .sheet(isPresented: $showOtherFieldsSheet) {
            OtherFieldsSheetView(
                headersText: $headersText,
                bodyText: $bodyText,
                isPresented: $showOtherFieldsSheet
            )
        }
    }

    private func loadConfiguration() {
        if hostModel.dataRaw != nil {
            name = hostModel.name

            if let customConfig = hostModel.getConfig(CustomHostConfig.self) {
                apiUrl = customConfig.url ?? ""
                method = customConfig.method
                fileField = customConfig.field ?? ""
                resultPath = customConfig.resultPath ?? ""
                domain = customConfig.domain
                saveKey = customConfig.saveKeyPath ?? "uPic/{filename}{.suffix}"
                useBase64 = customConfig.useBase64
            }
        }
    }

    private func saveConfiguration() {
        let customConfig = CustomHostConfig()
        customConfig.url = apiUrl
        customConfig.method = method
        customConfig.field = fileField
        customConfig.resultPath = resultPath
        customConfig.domain = domain
        customConfig.saveKeyPath = saveKey
        customConfig.useBase64 = useBase64

        hostModel.name = name
        if let jsonString = customConfig.toJSONString(), let jsonData = jsonString.data(using: .utf8) {
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

// Separate view for the Other Fields sheet
struct OtherFieldsSheetView: View {
    @Binding var headersText: String
    @Binding var bodyText: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Custom Fields Configuration")
                .font(.headline)
                .padding(.top)

            Form {
                Section(header: Text("Headers")) {
                    TextEditor(text: $headersText)
                        .frame(minHeight: 100)
                        .fontDesign(.monospaced)
                }

                Section(header: Text("Body")) {
                    TextEditor(text: $bodyText)
                        .frame(minHeight: 100)
                        .fontDesign(.monospaced)
                }
            }

            HStack {
                Spacer()

                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)

                Button("Save") {
                    // Save logic would be handled by the parent view
                    isPresented = false
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    let sampleHostModel = HostModel(.custom, data: nil)
    return CustomConfigView(hostModel: sampleHostModel)
        .modelContainer(for: HostModel.self, inMemory: true)
}
