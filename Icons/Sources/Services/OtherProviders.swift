//
//  OtherProviders.swift
//  Icons Free Version - Other AI Providers
//
//  Created by MightyKartz on 2024/11/18.
//

import Foundation

// MARK: - Anthropic Provider

class AnthropicProvider: BaseAIProvider {

    private let baseURL = "https://api.anthropic.com/v1"

    override func testConnection() async -> Bool {
        // TODO: 实现Anthropic连接测试
        return false
    }

    override func generateImage(request: GenerationRequest) async throws -> GenerationResult {
        // TODO: 实现Anthropic图像生成
        throw APIError.providerError("Anthropic提供商尚未实现")
    }
}

// MARK: - Stability AI Provider

class StabilityProvider: BaseAIProvider {

    private let baseURL = "https://api.stability.ai/v1"

    override func testConnection() async -> Bool {
        // TODO: 实现Stability AI连接测试
        return false
    }

    override func generateImage(request: GenerationRequest) async throws -> GenerationResult {
        // TODO: 实现Stability AI图像生成
        throw APIError.providerError("Stability AI提供商尚未实现")
    }
}

// MARK: - Google Provider

class GoogleProvider: BaseAIProvider {

    private let baseURL = "https://generativelanguage.googleapis.com/v1"

    override func testConnection() async -> Bool {
        // TODO: 实现Google连接测试
        return false
    }

    override func generateImage(request: GenerationRequest) async throws -> GenerationResult {
        // TODO: 实现Google图像生成
        throw APIError.providerError("Google提供商尚未实现")
    }
}

// MARK: - Custom Provider

class CustomProvider: BaseAIProvider {

    override func testConnection() async -> Bool {
        // TODO: 实现自定义提供商连接测试
        return false
    }

    override func generateImage(request: GenerationRequest) async throws -> GenerationResult {
        // TODO: 实现自定义提供商图像生成
        throw APIError.providerError("自定义提供商尚未实现")
    }
}