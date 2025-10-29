//
//  HostsSettingsView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import SwiftData
import UPicCore

struct HostsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var hostModels: [HostModel]
    @State private var selectedHostModel: HostModel? = nil

    var body: some View {
        HSplitView {
            // Left panel - Hosts List
            VStack(spacing: 0) {
                List(selection: $selectedHostModel) {
                    ForEach(hostModels) { hostModel in
                        HostListItem(
                            hostModel: hostModel,
                            isSelected: selectedHostModel?.id == hostModel.id,
                            onSelect: {
                                selectedHostModel = hostModel
                            },
                            onDelete: {
                                deleteHost(hostModel)
                            }
                        )
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }

                Spacer()

                HStack {
                    Spacer()
                    Menu {
                        ForEach(HostType.allCases, id: \.self) { hostType in
                            Button {
                                addHost(hostType)
                            } label: {
                                Label {
                                    Text(hostType.displayNname)
                                } icon: {
                                    Image("host_icon_\(hostType.rawValue)")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.primary, .blue)
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                }
            }
            .frame(minWidth: 200, idealWidth: 200, maxWidth: 250)

            // Right panel - Config view
            VStack {
                if let selectedHostModel = selectedHostModel {
                    configView(for: selectedHostModel)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "server.rack")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text("No Host Selected")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        Text("Select a host from the list or add a new one to configure upload settings.")
                            .font(.body)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Host")
    }

    @ViewBuilder
    private func configView(for hostModel: HostModel) -> some View {
        switch HostType(rawValue: hostModel.typeRaw ?? "") {
        case .smms:
            SmmsConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .weibo:
            WeiboConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .imgur:
            ImgurConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .s3:
            S3ConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .qiniu_kodo:
            QiniuConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .upyun_uss:
            UpyunConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .aliyun_oss:
            AliyunConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .tencent_cos:
            TencentConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .baidu_bos:
            BaiduConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .github:
            GithubConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .gitee:
            GiteeConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .custom:
            CustomConfigView(hostModel: hostModel)
                .id(hostModel.id)
        case .none:
            Text("Unknown host type")
                .foregroundStyle(.secondary)
        }
    }

    private func addHost(_ hostType: HostType) {
        let hostModel = HostModel(hostType, data: nil)
        modelContext.insert(hostModel)
        selectedHostModel = hostModel

        do {
            try modelContext.save()
        } catch {
            print("Failed to save host model: \(error)")
        }
    }

    private func deleteHost(_ hostModel: HostModel) {
        withAnimation {
            modelContext.delete(hostModel)
            if selectedHostModel?.id == hostModel.id {
                selectedHostModel = nil
            }

            do {
                try modelContext.save()
            } catch {
                print("Failed to delete host model: \(error)")
            }
        }
    }

    private func deleteHosts(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let hostModel = hostModels[index]
                modelContext.delete(hostModel)
                if selectedHostModel?.id == hostModel.id {
                    selectedHostModel = nil
                }
            }

            do {
                try modelContext.save()
            } catch {
                print("Failed to delete host models: \(error)")
            }
        }
    }
}

#Preview {
    HostsSettingsView()
}
