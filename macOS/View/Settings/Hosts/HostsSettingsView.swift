//
//  HostsSettingsView.swift
//  uPic(macOS)
//
//  Created by Licardo on 2025/10/28.
//

import SwiftUI
import UPicCore

struct HostsSettingsView: View {
    @State private var selectedHostType: HostType? = nil
    @State private var hosts: [HostType] = []

    var body: some View {
        HSplitView {
            // Left panel - Hosts List
            VStack(spacing: 0) {
                List(selection: $selectedHostType) {
                    ForEach(hosts, id: \.self) { hostType in
                        Label {
                            Text(hostType.displayNname)
                        } icon: {
                            Image("host_icon_\(hostType.rawValue)")
                        }
                    }
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
                if let selectedHostType = selectedHostType {
                    configView(for: selectedHostType)
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
    private func configView(for hostType: HostType) -> some View {
        switch hostType {
        case .smms:
            SmmsConfigView()
        case .weibo:
            WeiboConfigView()
        case .imgur:
            ImgurConfigView()
        case .s3:
            S3ConfigView()
        case .qiniu_kodo:
            QiniuConfigView()
        case .upyun_uss:
            UpyunConfigView()
        case .aliyun_oss:
            AliyunConfigView()
        case .tencent_cos:
            TencentConfigView()
        case .baidu_bos:
            BaiduConfigView()
        case .github:
            GithubConfigView()
        case .gitee:
            GiteeConfigView()
        case .custom:
            CustomConfigView()
        }
    }

    private func addHost(_ hostType: HostType) {
        if !hosts.contains(hostType) {
            hosts.append(hostType)
            selectedHostType = hostType
        }
    }
}

#Preview {
    HostsSettingsView()
}
