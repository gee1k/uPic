//
//  LibraryDetailView.swift
//  uPic
//
//  Created by Licardo on 2025/10/5.
//

import SwiftUI

struct LibraryDetailView: View {
    let library: LibraryInfo

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(library.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(library.author)
                        .font(.body)
                        .foregroundColor(.secondary)

                    Link("View on GitHub", destination: URL(string: library.githubURL)!)
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("License")
                        .font(.headline)

                    Text(library.licenseText)
                        .font(.caption)
                        .foregroundColor(.primary)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("License")
    }
}

#Preview {
    LibraryDetailView(library: libraries.first!)
}
