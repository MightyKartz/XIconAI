//
//  SettingsView.swift
//  Icons Free Version - Settings View
//
//  Created by MightyKartz on 2024/11/18.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @State private var showingAPIConfig = false
    @State private var showingClearHistoryAlert = false
    @State private var showingAbout = false

    var body: some View {
        Form {
            // API配置部分
            apiConfigurationSection

            // 历史记录部分
            historySection

            // 关于部分
            aboutSection

            // 诊断信息
            diagnosticsSection
        }
        .formStyle(.grouped)
        .navigationTitle("设置")
        .sheet(isPresented: $showingAPIConfig) {
            APIConfigView(appState: appState)
        }
        .alert("清除历史记录", isPresented: $showingClearHistoryAlert) {
            Button("取消", role: .cancel) { }
            Button("确认清除", role: .destructive) {
                appState.clearHistory()
            }
        } message: {
            Text("这将删除所有生成历史记录，此操作不可撤销。")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }

    // MARK: - API Configuration Section

    private var apiConfigurationSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("API配置")
                        .font(.headline)
                    Text(appState.isConfigured ? "已配置" : "未配置")
                        .font(.caption)
                        .foregroundColor(appState.isConfigured ? .green : .red)
                }

                Spacer()

                Button(appState.isConfigured ? "重新配置" : "配置") {
                    showingAPIConfig = true
                }
                .buttonStyle(.bordered)
            }

            if let config = appState.apiConfig {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("提供商:")
                            .foregroundColor(.secondary)
                        Text(config.provider.displayName)
                            .fontWeight(.medium)
                    }

                    HStack {
                        Text("模型:")
                            .foregroundColor(.secondary)
                        Text(config.model)
                            .fontWeight(.medium)
                    }

                    HStack {
                        Text("API密钥:")
                            .foregroundColor(.secondary)
                        Text(String(repeating: "•", count: min(config.apiKey.count, 20)))
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: - History Section

    private var historySection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("历史记录")
                        .font(.headline)
                    Text("共 \(appState.generationHistory.count) 条记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button("清除") {
                    showingClearHistoryAlert = true
                }
                .disabled(appState.generationHistory.isEmpty)
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            Button("关于 Icons") {
                showingAbout = true
            }

            HStack {
                Text("版本")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            Link("GitHub 仓库", destination: URL(string: "https://github.com/MightyKartz/icons")!)
        }
    }

    // MARK: - Diagnostics Section

    private var diagnosticsSection: some View {
        Section("诊断信息") {
            HStack {
                Text("应用状态")
                Spacer()
                Text(appState.isLoading ? "加载中" : "正常")
                    .foregroundColor(appState.isLoading ? .orange : .green)
            }

            if let errorMessage = appState.errorMessage {
                VStack(alignment: .leading, spacing: 4) {
                    Text("最近错误")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 2)
                }
            }

            Button("导出诊断信息") {
                exportDiagnostics()
            }
        }
    }

    // MARK: - Actions

    private func exportDiagnostics() {
        let diagnostics = """
        Icons 诊断信息
        ================

        时间: \(Date())
        版本: 1.0.0

        API配置状态: \(appState.isConfigured ? "已配置" : "未配置")
        历史记录数量: \(appState.generationHistory.count)
        当前加载状态: \(appState.isLoading ? "加载中" : "正常")

        \(appState.errorMessage.map { "最近错误: \($0)" } ?? "无最近错误")

        \(appState.apiConfig.map { "当前提供商: \($0.provider.displayName)" } ?? "无配置提供商")
        """

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.plainText]
        savePanel.nameFieldStringValue = "icons_diagnostics_\(Int(Date().timeIntervalSince1970)).txt"

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try diagnostics.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("导出诊断信息失败: \(error)")
                }
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 应用图标和名称
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)

                        Text("Icons")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("免费开源AI图标生成工具")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }

                    // 版本信息
                    VStack(spacing: 8) {
                        Text("版本 1.0.0")
                            .font(.headline)

                        Text("构建日期: 2024年11月")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // 功能描述
                    VStack(alignment: .leading, spacing: 16) {
                        Text("主要功能")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 12) {
                            FeatureItem(icon: "brain.head.profile", title: "多AI提供商支持", description: "支持OpenAI、ModelScope等多个AI服务")
                            FeatureItem(icon: "lock.shield", title: "隐私保护", description: "API密钥本地加密存储")
                            FeatureItem(icon: "bolt.circle", title: "快速生成", description: "秒级响应，实时预览")
                            FeatureItem(icon: "square.and.arrow.down", title: "多格式导出", description: "支持PNG、SVG等格式")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)

                    // 开源信息
                    VStack(spacing: 12) {
                        Text("开源项目")
                            .font(.headline)

                        Text("Icons 是一个完全开源的项目，使用MIT许可证。欢迎贡献代码和反馈问题。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Link("GitHub 仓库", destination: URL(string: "https://github.com/MightyKartz/icons")!)
                            .buttonStyle(.borderedProminent)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Feature Item

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        SettingsView(appState: AppState())
    }
}