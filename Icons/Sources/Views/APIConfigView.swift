//
//  APIConfigView.swift
//  Icons Free Version - API Configuration View
//
//  Created by MightyKartz on 2024/11/18.
//

import SwiftUI

struct APIConfigView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProvider: AIProvider = .modelscope
    @State private var apiKey: String = ""
    @State private var customBaseURL: String = ""
    @State private var selectedModel: String = ""
    @State private var isTestingConnection = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                VStack(spacing: 8) {
                    Image(systemName: "gear.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)

                    Text("API配置")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("配置AI提供商以开始生成图标")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // 配置表单
                Form {
                    // 提供商选择
                    Section("AI提供商") {
                        Picker("提供商", selection: $selectedProvider) {
                            ForEach(AIProvider.allCases, id: \.self) { provider in
                                HStack {
                                    Text(provider.displayName)
                                    Spacer()
                                    if provider.isFree {
                                        Text("免费")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                }
                                .tag(provider)
                            }
                        }
                        .onChange(of: selectedProvider) { _ in
                            updateDefaultModel()
                            if selectedProvider == .modelscope {
                                apiKey = "ms-f051cff4-82df-494a-9460-c30275e685b9"
                            } else {
                                apiKey = ""
                            }
                        }
                    }

                    // API密钥
                    Section("API密钥") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                TextField("输入API密钥", text: $apiKey)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(selectedProvider == .modelscope)

                                if selectedProvider == .modelscope {
                                    Text("默认")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            if !apiKey.isEmpty {
                                Text(getKeyHint())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // 自定义基础URL（仅自定义提供商）
                    if selectedProvider == .custom {
                        Section("基础URL") {
                            TextField("输入自定义API基础URL", text: $customBaseURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    // 模型选择
                    Section("模型") {
                        Picker("模型", selection: $selectedModel) {
                            ForEach(getAvailableModels(), id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                    }

                    // 连接测试
                    Section {
                        Button(action: testConnection) {
                            HStack {
                                if isTestingConnection {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("测试中...")
                                } else {
                                    Image(systemName: "network")
                                    Text("测试连接")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .disabled(apiKey.isEmpty || isTestingConnection)
                    }
                }
                .formStyle(.grouped)

                Spacer()

                // 保存按钮
                VStack(spacing: 16) {
                    Button(action: saveConfiguration) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("保存配置")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSave ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!canSave || isTestingConnection)

                    if appState.isConfigured {
                        Button("清除配置", role: .destructive) {
                            clearConfiguration()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("API配置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            loadExistingConfig()
        }
    }

    // MARK: - Computed Properties

    private var canSave: Bool {
        return !apiKey.isEmpty && !selectedModel.isEmpty
    }

    // MARK: - Helper Methods

    private func updateDefaultModel() {
        let models = selectedProvider.defaultModels
        if !models.isEmpty {
            selectedModel = models[0]
        } else {
            selectedModel = ""
        }
    }

    private func getAvailableModels() -> [String] {
        return selectedProvider.defaultModels
    }

    private func getKeyHint() -> String {
        switch selectedProvider {
        case .openai:
            return "OpenAI API密钥通常以'sk-'开头"
        case .anthropic:
            return "Anthropic API密钥通常以'sk-ant-'开头"
        case .modelscope:
            return "ModelScope提供免费API服务"
        case .stability:
            return "Stability AI API密钥格式较为复杂"
        case .google:
            return "Google AI API密钥较长"
        case .custom:
            return "请根据自定义提供商要求填写"
        }
    }

    // MARK: - Actions

    private func testConnection() {
        isTestingConnection = true

        Task {
            let config = APIConfig(
                provider: selectedProvider,
                apiKey: apiKey,
                baseURL: customBaseURL.isEmpty ? nil : customBaseURL,
                model: selectedModel
            )

            let isValid = await appState.testAPIConnection(config)

            await MainActor.run {
                isTestingConnection = false
                if isValid {
                    alertMessage = "连接测试成功！"
                } else {
                    alertMessage = "连接测试失败，请检查配置"
                }
                showingAlert = true
            }
        }
    }

    private func saveConfiguration() {
        let config = APIConfig(
            provider: selectedProvider,
            apiKey: apiKey,
            baseURL: customBaseURL.isEmpty ? nil : customBaseURL,
            model: selectedModel
        )

        appState.saveAPIConfig(config)
        dismiss()
    }

    private func clearConfiguration() {
        appState.clearAPIConfig()
        dismiss()
    }

    private func loadExistingConfig() {
        if let config = appState.apiConfig {
            selectedProvider = config.provider
            apiKey = config.apiKey
            selectedModel = config.model
            customBaseURL = config.baseURL ?? ""
        } else {
            updateDefaultModel()
            if selectedProvider == .modelscope {
                apiKey = "ms-f051cff4-82df-494a-9460-c30275e685b9"
            }
        }
    }
}

#Preview {
    APIConfigView(appState: AppState())
}