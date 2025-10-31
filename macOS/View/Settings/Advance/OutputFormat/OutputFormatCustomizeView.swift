//
//  OutputFormatCustomizeView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import Defaults
import SwiftUI

struct OutputFormatCustomizeView: View {
    @Default(.outputFormats) var originalOutputFormats
    @State private var editableOutputFormats: [OutputFormatModel] = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            Text("Output Format Customization")
                .font(.headline)
                .fontWeight(.semibold)

            Table(editableOutputFormats) {
                TableColumn("Name") { format in
                    TextField("Format Name", text: binding(for: format, keyPath: \.name))
                        .textFieldStyle(.roundedBorder)
                }
                .width(150)

                TableColumn("Format") { format in
                    TextField("Format Value", text: binding(for: format, keyPath: \.value))
                        .textFieldStyle(.roundedBorder)
                        .fontDesign(.monospaced)
                }

                TableColumn("Delete") { format in
                    Button {
                        deleteFormat(format)
                    } label: {
                        Image(systemName: "x.circle")
                            .foregroundStyle(.red)
                            .frame(width: 40, alignment: .center)
                    }
                    .buttonStyle(.plain)
                    .help("Delete format")
                }
                .width(40)
            }
            .tableStyle(.bordered)
            .frame(minHeight: 200)

            HStack {
                Text("Note: Please use {url} {filename} as placeholder for your url")
                Spacer()
                Button {
                    addNewFormat()
                } label: {
                    Image(systemName: "plus")
                }
            }
            .padding(.vertical)

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
        .frame(minWidth: 600, minHeight: 400)
        .padding()
        .onAppear {
            editableOutputFormats = originalOutputFormats
        }
    }

    private func binding(for element: OutputFormatModel, keyPath: WritableKeyPath<OutputFormatModel, String>) -> Binding<String> {
        guard let index = editableOutputFormats.firstIndex(where: { $0.id == element.id }) else {
            fatalError("Element not found in array")
        }

        return Binding(
            get: {
                editableOutputFormats[index][keyPath: keyPath]
            },
            set: { newValue in
                editableOutputFormats[index][keyPath: keyPath] = newValue
            }
        )
    }

    private func addNewFormat() {
        let newFormat = OutputFormatModel(
            name: "New Format",
            value: "{url}"
        )
        editableOutputFormats.append(newFormat)
    }

    private func deleteFormat(_ format: OutputFormatModel) {
        editableOutputFormats.removeAll { $0.id == format.id }
    }

    private func saveChanges() {
        let validFormats = editableOutputFormats.filter { format in
            !format.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                !format.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        Defaults[.outputFormats] = validFormats

        dismiss()
    }
}

#Preview {
    OutputFormatCustomizeView()
}
