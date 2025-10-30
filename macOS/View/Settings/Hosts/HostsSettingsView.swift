//
//  HostsSettingsView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import Defaults
import SimpleLogger
import SwiftData
import SwiftUI
import UPicCore

struct HostsSettingsView: View {
    @Default(.selectedHostId) var selectedHostId

    @State private var selectedHostModel: HostModel? = nil
    @State private var tempHostModels: [HostModel] = []

    @Environment(\.modelContext) private var modelContext
    @Query private var hostModels: [HostModel]

    // Combine persisted hosts and temporary hosts
    private var allHostModels: [HostModel] {
        hostModels + tempHostModels
    }

    var body: some View {
        HSplitView {
            // Left panel - Hosts List
            VStack(spacing: 0) {
                List(selection: $selectedHostModel) {
                    ForEach(allHostModels) { hostModel in
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
                            .foregroundStyle(.white, .blue)
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
                }
                .padding(.bottom, 8)
                .padding(.trailing, 4)
                .padding(.top, -8)
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

                        Text("Select a host from the list or add a new one to configure.")
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
            SmmsConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .weibo:
            WeiboConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .imgur:
            ImgurConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .s3:
            S3ConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .qiniu_kodo:
            QiniuConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .upyun_uss:
            UpyunConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .aliyun_oss:
            AliyunConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .tencent_cos:
            TencentConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .baidu_bos:
            BaiduConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .github:
            GithubConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .gitee:
            GiteeConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .custom:
            CustomConfigView(hostModel: hostModel) {
                saveHostToDatabase(hostModel)
            }
            .id(hostModel.id)
        case .none:
            Text("Unknown host type")
                .foregroundStyle(.secondary)
        }
    }

    private func addHost(_ hostType: HostType) {
        let hostModel = HostModel(hostType, data: nil)
        tempHostModels.append(hostModel)
        selectedHostModel = hostModel
    }

    private func deleteHost(_ hostModel: HostModel) {
        withAnimation {
            if let tempIndex = tempHostModels.firstIndex(where: { $0.id == hostModel.id }) {
                tempHostModels.remove(at: tempIndex)
            } else {
                modelContext.delete(hostModel)
                do {
                    try modelContext.save()
                } catch {
                    AppLogger.hosts.error("Failed to delete host model: \(error.localizedDescription)")
                }
            }

            if selectedHostId == hostModel.id {
                if hostModels.count == 0 {
                    selectedHostId = nil
                } else {
                    selectedHostId = hostModels.first?.id
                }
            }
        }
    }

    func saveHostToDatabase(_ hostModel: HostModel) {
        withAnimation {
            modelContext.insert(hostModel)

            if let tempIndex = tempHostModels.firstIndex(where: { $0.id == hostModel.id }) {
                tempHostModels.remove(at: tempIndex)
            }

            do {
                try modelContext.save()
                AppLogger.hosts.info("Host saved successfully to database: \(hostModel.name ?? "") \(hostModel.typeRaw ?? "")")
            } catch {
                AppLogger.hosts.error("Failed to save host to database: \(hostModel.name ?? "") \(hostModel.typeRaw ?? ""). Error: \(error.localizedDescription)")
            }

            if hostModels.count == 1 {
                selectedHostId = hostModel.id
            }
        }
    }
}

#Preview {
    HostsSettingsView()
}
