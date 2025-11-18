//
//  AppState.swift
//  Icons Free Version - Application State Management
//
//  Created by MightyKartz on 2024/11/18.
//

import SwiftUI
import Foundation
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var apiConfig: APIConfig?
    @Published var isConfigured: Bool = false
    @Published var generationHistory: [GenerationResult] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadLocalConfig()
        setupErrorHandling()
    }

    // MARK: - Configuration Management

    func saveAPIConfig(_ config: APIConfig) {
        do {
            let data = try JSONEncoder().encode(config)
            let encryptedData = try CryptoUtils.encrypt(data)
            UserDefaults.standard.set(encryptedData, forKey: "encryptedAPIConfig")

            self.apiConfig = config
            self.isConfigured = true
            self.errorMessage = nil

            print("API配置已保存")
        } catch {
            self.errorMessage = "保存配置失败: \(error.localizedDescription)"
        }
    }

    func loadLocalConfig() {
        guard let encryptedData = UserDefaults.standard.data(forKey: "encryptedAPIConfig") else {
            return
        }

        do {
            let decryptedData = try CryptoUtils.decrypt(encryptedData)
            let config = try JSONDecoder().decode(APIConfig.self, from: decryptedData)

            self.apiConfig = config
            self.isConfigured = true
        } catch {
            print("加载配置失败: \(error.localizedDescription)")
            clearAPIConfig()
        }
    }

    func clearAPIConfig() {
        UserDefaults.standard.removeObject(forKey: "encryptedAPIConfig")
        self.apiConfig = nil
        self.isConfigured = false
    }

    func testAPIConnection(_ config: APIConfig) async -> Bool {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let provider = AIProviderFactory.createProvider(for: config.provider, config: config)
            let isValid = await provider.testConnection()

            if isValid {
                print("API连接测试成功")
            } else {
                errorMessage = "API连接测试失败"
            }

            return isValid
        } catch {
            errorMessage = "连接测试异常: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Generation Management

    func addToHistory(_ result: GenerationResult) {
        generationHistory.insert(result, at: 0)

        // 保持历史记录在合理范围内
        if generationHistory.count > 50 {
            generationHistory = Array(generationHistory.prefix(50))
        }
    }

    func clearHistory() {
        generationHistory.removeAll()
    }

    // MARK: - Private Methods

    private func setupErrorHandling() {
        // 处理网络错误、API限制等情况
        // 可以在这里添加错误恢复逻辑
    }
}

// MARK: - Extension for Error Handling

extension AppState {
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription

        // 根据错误类型提供用户友好的提示
        if case APIError.rateLimitExceeded = error {
            errorMessage = "API调用频率过高，请稍后重试"
        } else if case APIError.invalidAPIKey = error {
            errorMessage = "API密钥无效，请检查配置"
        } else if case APIError.insufficientCredits = error {
            errorMessage = "API额度不足，请检查账户余额"
        }
    }
}