//
//  HostConfigSwitchView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/31.
//

import Defaults
import SimpleLogger
import SwiftData
import SwiftUI
import UPicCore

struct HostConfigSwitchView: View {
    var hostModel: HostModel
    @Binding var tempHostModels: [HostModel]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var hostModels: [HostModel]

    @Default(.selectedHostId) var selectedHostId
    @State private var isDismissing = false

    var body: some View {
        Group {
            switch HostType(rawValue: hostModel.typeRaw ?? "") {
            case .smms:
                SmmsConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .weibo:
                WeiboConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .imgur:
                ImgurConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .s3:
                S3ConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .qiniu_kodo:
                QiniuConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .upyun_uss:
                UpyunConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .aliyun_oss:
                AliyunConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .tencent_cos:
                TencentConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .baidu_bos:
                BaiduConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .github:
                GithubConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .gitee:
                GiteeConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .custom:
                CustomConfigView(hostModel: hostModel) {
                    saveHostToDatabase(hostModel)
                } onCancel: {
                    onCancel()
                } onValidate: {
                    validateHost(hostModel)
                }
                .id(hostModel.id)
            case .none:
                Text("Unknown host type")
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(isDismissing ? 0.0 : 1.0)
        .onChange(of: isDismissing) { _, isDismissing in
            if isDismissing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dismiss()
                }
            }
        }
    }

    private func saveHostToDatabase(_ hostModel: HostModel) {
        if hostModels.count == 0 { // 如果原来没有任何 host，这次添加的是第一个，设置为默认 Host
            selectedHostId = hostModel.id
        }

        modelContext.insert(hostModel)

        if let tempIndex = tempHostModels.firstIndex(where: { $0.id == hostModel.id }) {
            tempHostModels.remove(at: tempIndex)
        }

        do {
            try modelContext.save()
            AppLogger.host.info("Host saved successfully to database: \(hostModel.name) \(hostModel.typeRaw ?? "")")
        } catch {
            AppLogger.host.error("Failed to save host to database: \(hostModel.name) \(hostModel.typeRaw ?? ""). Error: \(error.localizedDescription)")
        }
    }

    private func validateHost(_ hostModel: HostModel) {
        if let image = NSImage(named: "uPic") {
            Task {
                await UploadeManager.shared.upload(hostModel: hostModel, images: [image])
            }
        }
    }

    private func onCancel() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDismissing = true
        }

        // 移除临时数据
        tempHostModels.removeAll { $0.id == hostModel.id }
    }
}

#Preview {
    HostConfigSwitchView(hostModel: HostModel(), tempHostModels: .constant([]))
}
