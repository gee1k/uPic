//
//  AboutSettingsView.swift
//  uPic
//
//  Created by Licardo on 2025/9/30.
//

import SimpleLogger
import SwiftUI

struct AboutSettingsView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    HStack {
                        Label {
                            Text("GitHub")
                        } icon: {
                            Image("host_icon_github")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                        Spacer()
                        Button {
                            if let url = URL(string: Constants.githubHomepage) {
                                openURL(url)
                            }
                        } label: {
                            Text(verbatim: Constants.githubHomepage)
                        }
                        .buttonStyle(.link)
                    }
                    
                    HStack {
                        Label("Home Page", systemImage: "house")
                        Spacer()
                        Button {
                            if let url = URL(string: Constants.svendHomepage) {
                                openURL(url)
                            }
                        } label: {
                            Text(verbatim: Constants.svendHomepage)
                        }
                        .buttonStyle(.link)
                    }
                    
                    HStack {
                        Label("Email", systemImage: "envelope")
                        Spacer()
                        Button {
                            createTempLogAndSendEmail()
                        } label: {
                            Text(verbatim: Constants.svendEmail)
                        }
                        .buttonStyle(.link)
                    }
                } header: {
                    Text("Contact")
                }
                
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(getAppVersion())
                    }
                    
                    HStack {
                        Label("Rate App", systemImage: "hand.thumbsup")
                        Spacer()
                        Button {
                            if let url = URL(string: Constants.appStoreReviewURL) {
                                openURL(url)
                            }
                        } label: {
                            Text("Thumbs up in App Store")
                        }
                        .buttonStyle(.link)
                    }
                } header: {
                    Text("Application")
                }
                
                Section {
                    NavigationStack {
                        NavigationLink {
                            OpenSourceLicensesView()
                        } label: {
                            Label {
                                Text("Open Source Licenses")
                            } icon: {
                                Image("host_icon_github")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                            }
                        }
                    }
                } header: {
                    Text("Acknowledgments")
                }
            }
            .formStyle(.grouped)
            
            Spacer()
            
            HStack(alignment: .center, spacing: 4) {
                Spacer()
                Text(verbatim: "MADE WITH")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Image("Heart")
                    .resizable()
                    .frame(width: 10, height: 10)
                Text("BY SVEND AND [MORE](\(Constants.githubContributors))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.bottom, 4)
        }
        .navigationTitle("About")
        .formStyle(.grouped)
    }
    
    private func createTempLogAndSendEmail() {
        AppLogger.settings.info("Start sending email with log")
        let logFileURL = getLogFileURL()
        let deviceInfo = getDeviceInfo()
        let appVersion = getAppVersion()

        let subject = "uPic Support - \(appVersion)"
        let body = """
        
        
        
        \(String(localized: "Please do NOT delete the info below"))
        
        ------------------------------------------------------------
        App Version: \(appVersion)
        
        Device Info: \(deviceInfo)
        ------------------------------------------------------------
        
        """

        sendEmailWithAttachment(subject: subject, body: body, attachmentURL: logFileURL)
    }

    private func sendEmailWithAttachment(subject: String, body: String, attachmentURL: URL?) {
        let email = Constants.svendEmail

        let sharingService = NSSharingService(named: .composeEmail)
        if let sharingService = sharingService {
            sharingService.recipients = [email]
            sharingService.subject = subject

            // 直接将正文文本和附件文件URL一起分享
            let items: [Any] = [body, attachmentURL as Any]

            sharingService.perform(withItems: items)
            AppLogger.settings.info("Successfully opened email")
        } else {
            AppLogger.settings.error("Email service is not available")
        }
    }

    private func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"], let buildNum = Bundle.main.infoDictionary?["CFBundleVersion"] {
            return "v\(version)(\(buildNum))"
        }
        return String(localized: "unknown")
    }
    
    private func getDeviceInfo() -> String {
        var info: [String] = []
        
        info.append("")
        
        // macOS版本
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        info.append("macOS: \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)")
        
        // 设备型号
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        let deviceModel = String(cString: model)
        info.append("Model: \(deviceModel)")
        
        // CPU信息
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        var cpu = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &cpu, &size, nil, 0)
        let cpuBrand = String(cString: cpu)
        info.append("CPU: \(cpuBrand)")
        
        // 内存信息
        var memSize: UInt64 = 0
        size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &memSize, &size, nil, 0)
        let memoryGB = Double(memSize) / (1024 * 1024 * 1024)
        info.append("Memory: \(String(format: "%.1f", memoryGB)) GB")
        
        return info.joined(separator: "\n")
    }
    
    private func getLogFileURL() -> URL? {
        guard let groupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier) else {
            return nil
        }
        
        let logsDirectory = groupContainer.appendingPathComponent("Logs")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        let logFileName = "uPic-\(today).log"
        let logFileURL = logsDirectory.appendingPathComponent(logFileName)
        
        // 检查文件是否存在
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            return logFileURL
        } else {
            return nil
        }
    }
}

#Preview {
    AboutSettingsView()
}
