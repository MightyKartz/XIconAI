//
//  AIProviderFactory.swift
//  Icons Free Version - AI Provider Factory
//
//  Created by MightyKartz on 2024/11/18.
//

import Foundation

class AIProviderFactory {

    // MARK: - Provider Creation

    static func createProvider(for provider: AIProvider, config: APIConfig) -> AIProviderProtocol {
        switch provider {
        case .openai:
            return OpenAIProvider(config: config)
        case .anthropic:
            return AnthropicProvider(config: config)
        case .stability:
            return StabilityProvider(config: config)
        case .google:
            return GoogleProvider(config: config)
        case .custom:
            return CustomProvider(config: config)
        }
    }

    // MARK: - Provider Validation

    static func validateConfig(_ config: APIConfig) -> ValidationResult {
        guard !config.apiKey.isEmpty else {
            return ValidationResult(isValid: false, error: "API密钥不能为空")
        }

        guard !config.model.isEmpty else {
            return ValidationResult(isValid: false, error: "模型不能为空")
        }

        guard CryptoUtils.isValidAPIKey(config.apiKey, for: config.provider) else {
            return ValidationResult(isValid: false, error: "API密钥格式不正确")
        }

        if let baseURL = config.baseURL, !baseURL.isEmpty {
            guard URL(string: baseURL) != nil else {
                return ValidationResult(isValid: false, error: "基础URL格式不正确")
            }
        }

        return ValidationResult(isValid: true, error: nil)
    }
}

// MARK: - Validation Result

struct ValidationResult {
    let isValid: Bool
    let error: String?
}

// MARK: - AI Provider Protocol

protocol AIProviderProtocol {
    var config: APIConfig { get }

    func testConnection() async -> Bool
    func generateImage(request: GenerationRequest) async throws -> GenerationResult
}

// MARK: - Base Provider Implementation

class BaseAIProvider: AIProviderProtocol {
    let config: APIConfig

    init(config: APIConfig) {
        self.config = config
    }

    func testConnection() async -> Bool {
        // 默认实现，子类应该重写
        return false
    }

    func generateImage(request: GenerationRequest) async throws -> GenerationResult {
        // 默认实现，子类应该重写
        throw APIError.providerError("未实现生成功能")
    }

    // MARK: - HTTP Client

    protected func makeRequest(url: URL, method: String = "GET", body: Data? = nil, headers: [String: String] = [:]) async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            request.httpBody = body
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        guard 200...299 ~= httpResponse.statusCode else {
            if httpResponse.statusCode == 401 {
                throw APIError.invalidAPIKey
            } else if httpResponse.statusCode == 429 {
                throw APIError.rateLimitExceeded
            } else if httpResponse.statusCode == 402 {
                throw APIError.insufficientCredits
            } else {
                throw APIError.providerError("HTTP错误: \(httpResponse.statusCode)")
            }
        }

        return (data, httpResponse)
    }
}