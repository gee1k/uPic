//
//  MenuBarProgressView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/29.
//

import SwiftUI

struct MenuBarProgressView: View {
    let isUploading: Bool
    let uploadProgress: Double

    var body: some View {
        if isUploading {
            // 使用系统ProgressView作为上传状态
            ProgressView()
                .controlSize(.small)
                .scaleEffect(0.8)
        } else {
            // 正常状态图标
            Image("statusMenuIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        MenuBarProgressView(isUploading: false, uploadProgress: 0.0)
        MenuBarProgressView(isUploading: true, uploadProgress: 0.5)
    }
    .padding()
    .background(Color.black)
}