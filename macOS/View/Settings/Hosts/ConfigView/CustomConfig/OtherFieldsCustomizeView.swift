//
//  OtherFieldsCustomizeView.swift
//  uPic
//
//  Created by Licardo on 2025/10/30.
//

import SwiftUI
import UPicCore

struct OtherFieldsCustomizeView: View {
    @Binding var headers: [(String, String)]
    @Binding var bodies: [(String, String)]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            Text("Headers and Bodies Customization")
                .font(.headline)
                .fontWeight(.semibold)

            // Headers Section
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "textformat.size")
                        .foregroundColor(.blue)
                    Text("Headers")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        addNewHeader()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    .help("Add new header")
                }

                VStack(spacing: 4) {
                    HStack {
                        Text("Key")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 200, alignment: .leading)
                        Text("Value")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("")
                            .frame(width: 40)
                    }
                    .padding(.horizontal, 8)

                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(headers.indices, id: \.self) { index in
                                HStack {
                                    TextField("Header Key", text: Binding(
                                        get: { headers[index].0 },
                                        set: { headers[index].0 = $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 200)

                                    TextField("Header Value", text: Binding(
                                        get: { headers[index].1 },
                                        set: { headers[index].1 = $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .fontDesign(.monospaced)

                                    Button {
                                        deleteHeader(at: index)
                                    } label: {
                                        Image(systemName: "x.circle")
                                            .foregroundStyle(.red)
                                            .frame(width: 40, alignment: .center)
                                    }
                                    .buttonStyle(.plain)
                                    .help("Delete header")
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                    }
                }
                .frame(minHeight: 100)
                .border(Color.gray.opacity(0.3))
            }
            .padding(.vertical, 8)

            // Bodies Section
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.green)
                    Text("Bodies")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        addNewBody()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                    .help("Add new body field")
                }

                VStack(spacing: 4) {
                    HStack {
                        Text("Key")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 200, alignment: .leading)
                        Text("Value")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("")
                            .frame(width: 40)
                    }
                    .padding(.horizontal, 8)

                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(bodies.indices, id: \.self) { index in
                                HStack {
                                    TextField("Body Key", text: Binding(
                                        get: { bodies[index].0 },
                                        set: { bodies[index].0 = $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 200)

                                    TextField("Body Value", text: Binding(
                                        get: { bodies[index].1 },
                                        set: { bodies[index].1 = $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .fontDesign(.monospaced)

                                    Button {
                                        deleteBody(at: index)
                                    } label: {
                                        Image(systemName: "x.circle")
                                            .foregroundStyle(.red)
                                            .frame(width: 40, alignment: .center)
                                    }
                                    .buttonStyle(.plain)
                                    .help("Delete body")
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                    }
                }
                .frame(minHeight: 100)
                .border(Color.gray.opacity(0.3))
            }
            .padding(.vertical, 8)

            Text("Note: Use {url}, {filename}, and other placeholders in your values")
                .font(.caption)
                .foregroundColor(.secondary)

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
    }

    private func addNewHeader() {
        let newHeader = ("X-Custom-Header", "{filename}")
        headers.append(newHeader)
    }

    private func addNewBody() {
        let newBody = ("filename", "{filename}")
        bodies.append(newBody)
    }

    private func deleteHeader(at index: Int) {
        guard index < headers.count else { return }
        headers.remove(at: index)
    }

    private func deleteBody(at index: Int) {
        guard index < bodies.count else { return }
        bodies.remove(at: index)
    }

    private func saveChanges() {
        dismiss()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var headers: [(String, String)] = [
            ("X-Custom-Header", "{filename}"),
            ("Authorization", "Bearer token")
        ]
        @State var bodies: [(String, String)] = [
            ("filename", "{filename}"),
            ("url", "{url}")
        ]

        var body: some View {
            OtherFieldsCustomizeView(headers: $headers, bodies: $bodies)
        }
    }

    return PreviewWrapper()
}
