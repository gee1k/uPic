//
//  OtherFieldsCustomizeView.swift
//  uPic
//
//  Created by Licardo on 2025/10/30.
//

import SwiftUI
import UPicCore

struct OtherFieldsCustomizeView: View {
    @Binding var headers: [HeaderOrBodyModel]
    @Binding var bodies: [HeaderOrBodyModel]
    @State private var editableHeaders: [HeaderOrBodyModel] = []
    @State private var editableBodies: [HeaderOrBodyModel] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            Text("Headers and Bodies Customization")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.bottom, 2)

            // Headers Table
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "textformat.size")
                        .foregroundStyle(.blue)
                    Text("Header")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        addNewHeader()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                    .help("Add new header")
                }

                Table(editableHeaders) {
                    TableColumn("Key") { header in
                        TextField("Header Key", text: binding(for: header, keyPath: \.key))
                            .textFieldStyle(.roundedBorder)
                    }
                    .width(200)

                    TableColumn("Value") { header in
                        TextField("Header Value", text: binding(for: header, keyPath: \.value))
                            .textFieldStyle(.roundedBorder)
                            .fontDesign(.monospaced)
                    }

                    TableColumn("Delete") { header in
                        Button {
                            deleteHeader(header)
                        } label: {
                            Image(systemName: "x.circle")
                                .foregroundStyle(.red)
                                .frame(width: 40, alignment: .center)
                        }
                        .buttonStyle(.plain)
                        .help("Delete header")
                    }
                    .width(40)
                }
                .tableStyle(.bordered)
                .frame(minHeight: 100)
            }
            .padding(.bottom, 4)

            // Bodies Table
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.green)
                    Text("Body")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        addNewBody()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.plain)
                    .help("Add new body")
                }

                Table(editableBodies) {
                    TableColumn("Key") { body in
                        TextField("Body Key", text: binding(for: body, keyPath: \.key))
                            .textFieldStyle(.roundedBorder)
                    }
                    .width(200)

                    TableColumn("Value") { body in
                        TextField("Body Value", text: binding(for: body, keyPath: \.value))
                            .textFieldStyle(.roundedBorder)
                            .fontDesign(.monospaced)
                    }

                    TableColumn("Delete") { body in
                        Button {
                            deleteBody(body)
                        } label: {
                            Image(systemName: "x.circle")
                                .foregroundStyle(.red)
                                .frame(width: 40, alignment: .center)
                        }
                        .buttonStyle(.plain)
                        .help("Delete body")
                    }
                    .width(40)
                }
                .tableStyle(.bordered)
                .frame(minHeight: 100)
            }

            Text("Supports {year} {month} {day} {hour} {minute} {second} {since_second} {since_millisecond} {random} {filename} {.suffix} {suffix} {mimetype} {saveKey} and etc.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(width: 80)
                }
                .keyboardShortcut(.escape)

                Button {
                    saveChanges()
                } label: {
                    Text("Save")
                        .frame(width: 80)
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .padding()
        .onAppear {
            editableHeaders = headers
            editableBodies = bodies
        }
    }

    private func binding(for element: HeaderOrBodyModel, keyPath: WritableKeyPath<HeaderOrBodyModel, String>) -> Binding<String> {
        guard let index = editableHeaders.firstIndex(where: { $0.id == element.id }) ?? editableBodies.firstIndex(where: { $0.id == element.id }) else {
            fatalError("Element not found in array")
        }

        let isArrayHeaders = editableHeaders.contains { $0.id == element.id }

        return Binding(
            get: {
                if isArrayHeaders {
                    return editableHeaders[index][keyPath: keyPath]
                } else {
                    return editableBodies[index][keyPath: keyPath]
                }
            },
            set: { newValue in
                if isArrayHeaders {
                    editableHeaders[index][keyPath: keyPath] = newValue
                } else {
                    editableBodies[index][keyPath: keyPath] = newValue
                }
            }
        )
    }

    private func addNewHeader() {
        let newHeader = HeaderOrBodyModel(key: "X-Custom-Header", value: "{filename}")
        editableHeaders.append(newHeader)
    }

    private func addNewBody() {
        let newBody = HeaderOrBodyModel(key: "filename", value: "{filename}")
        editableBodies.append(newBody)
    }

    private func deleteHeader(_ header: HeaderOrBodyModel) {
        editableHeaders.removeAll { $0.id == header.id }
    }

    private func deleteBody(_ body: HeaderOrBodyModel) {
        editableBodies.removeAll { $0.id == body.id }
    }

    private func saveChanges() {
        headers = editableHeaders
        bodies = editableBodies
        dismiss()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var headers: [HeaderOrBodyModel] = [
            HeaderOrBodyModel(key: "X-Custom-Header", value: "{filename}"),
            HeaderOrBodyModel(key: "Authorization", value: "Bearer token")
        ]
        @State var bodies: [HeaderOrBodyModel] = [
            HeaderOrBodyModel(key: "filename", value: "{filename}"),
            HeaderOrBodyModel(key: "url", value: "{url}")
        ]

        var body: some View {
            OtherFieldsCustomizeView(headers: $headers, bodies: $bodies)
        }
    }

    return PreviewWrapper()
}
