//
//  CustomConfigView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import UPicCore

struct CustomConfigView: View {
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
                    if let url = URL(string: "https://blog.svend.cc/upic/tutorials/custom") {
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
        .sheet(isPresented: $showOtherFieldsSheet) {
            OtherFieldsSheetView(
                headersText: $headersText,
                bodyText: $bodyText,
                isPresented: $showOtherFieldsSheet
            )
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
    CustomConfigView()
}
