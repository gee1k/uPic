//
//  OpenSourceLicensesView.swift
//  uPic
//
//  Created by Licardo on 2025/10/4.
//

import SwiftUI

struct OpenSourceLicensesView: View {
    var body: some View {
        Form {
            Section {
                ForEach(libraries) { library in
                    NavigationLink {
                        LibraryDetailView(library: library)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(library.name)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text(library.author)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                HStack {
                    Image("host_icon_github")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("Open Source Libraries")
                        .font(.headline)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Open Source")
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationView {
        OpenSourceLicensesView()
    }
}
