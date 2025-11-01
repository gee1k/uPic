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
            .frame(minWidth: 200, idealWidth: 200, maxWidth: 250)

            // Right panel - Config view
            VStack {
                if let selectedHostModel = selectedHostModel {
                    HostConfigSwitchView(hostModel: selectedHostModel, tempHostModels: $tempHostModels)
                } else if allHostModels.isEmpty {
                    NoHostView()
                } else {
                    SelectAHostView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Host")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    ForEach(HostType.allCases, id: \.self) { hostType in
                        Button {
                            addHost(hostType)
                        } label: {
                            Label {
                                Text(hostType.displayNname)
                            } icon: {
                                Image("host_icon_\(hostType.rawValue)_small")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.white, .blue)
                }
                .menuIndicator(.hidden)
            }
        }
    }

    private func addHost(_ hostType: HostType) {
        withAnimation {
            let hostModel = HostModel(hostType, data: nil)
            tempHostModels.append(hostModel)
            selectedHostModel = hostModel
        }
    }

    private func deleteHost(_ hostModel: HostModel) {
        withAnimation {
            if selectedHostModel == hostModel {
                selectedHostModel = nil
            }

            if let tempIndex = tempHostModels.firstIndex(where: { $0.id == hostModel.id }) {
                tempHostModels.remove(at: tempIndex)
            } else {
                modelContext.delete(hostModel)
                do {
                    try modelContext.save()
                } catch {
                    AppLogger.host.error("Failed to delete host model: \(error.localizedDescription)")
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
}

#Preview {
    HostsSettingsView()
}
