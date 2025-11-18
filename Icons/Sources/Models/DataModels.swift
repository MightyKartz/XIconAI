//
//  DataModels.swift
//  Icons Free Version - Data Models
//
//  Created by MightyKartz on 2024/11/18.
//

import Foundation

// MARK: - AI Provider Enum
enum AIProvider: String, CaseIterable, Codable {
    case openai = "openai"
    case anthropic = "anthropic"
    case stability = "stability"
    case google = "google"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .openai:
            return "OpenAI"
        case .anthropic:
            return "Anthropic"
        case .stability:
            return "Stability AI"
        case .google:
            return "Google"
        case .custom:
            return "自定义"
        }
    }

    var defaultModels: [String] {
        switch self {
        case .openai:
            return ["dall-e-3", "dall-e-2"]
        case .anthropic:
            return ["claude-3-vision"]
        case .stability:
            return ["stable-diffusion-xl", "stable-diffusion-3"]
        case .google:
            return ["gemini-pro-vision"]
        case .custom:
            return []
        }
    }

    var isFree: Bool {
        switch self {
        default:
            return false
        }
    }
}

// MARK: - API Configuration
struct APIConfig: Codable {
    let provider: AIProvider
    let apiKey: String
    let baseURL: String?
    let model: String
    let isEnabled: Bool

    init(provider: AIProvider, apiKey: String, baseURL: String? = nil, model: String, isEnabled: Bool = true) {
        self.provider = provider
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.model = model
        self.isEnabled = isEnabled
    }
}

// MARK: - Generation Request
struct GenerationRequest: Codable {
    let prompt: String
    let style: String?
    let size: String
    let quality: String?
    let provider: AIProvider
    let model: String
    let count: Int

    init(prompt: String, style: String? = nil, size: String = "1024x1024", quality: String? = nil, provider: AIProvider, model: String, count: Int = 1) {
        self.prompt = prompt
        self.style = style
        self.size = size
        self.quality = quality
        self.provider = provider
        self.model = model
        self.count = count
    }
}

// MARK: - Generation Result
struct GenerationResult: Codable, Identifiable {
    let id: UUID
    let prompt: String
    let provider: AIProvider
    let model: String
    let imageData: Data?
    let imageURL: String?
    let timestamp: Date
    let processingTime: TimeInterval
    let isSuccessful: Bool
    let errorMessage: String?

    init(id: UUID = UUID(), prompt: String, provider: AIProvider, model: String, imageData: Data? = nil, imageURL: String? = nil, timestamp: Date = Date(), processingTime: TimeInterval, isSuccessful: Bool, errorMessage: String? = nil) {
        self.id = id
        self.prompt = prompt
        self.provider = provider
        self.model = model
        self.imageData = imageData
        self.imageURL = imageURL
        self.timestamp = timestamp
        self.processingTime = processingTime
        self.isSuccessful = isSuccessful
        self.errorMessage = errorMessage
    }
}

// MARK: - Task Status
enum TaskStatus: String, Codable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"

    var displayName: String {
        switch self {
        case .pending:
            return "等待中"
        case .processing:
            return "处理中"
        case .completed:
            return "已完成"
        case .failed:
            return "失败"
        }
    }
}

// MARK: - Generation Task
struct GenerationTask: Codable, Identifiable {
    let id: String
    let request: GenerationRequest
    let status: TaskStatus
    let progress: Double
    let result: GenerationResult?
    let createdAt: Date
    let updatedAt: Date

    init(id: String = UUID().uuidString, request: GenerationRequest, status: TaskStatus = .pending, progress: Double = 0.0, result: GenerationResult? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.request = request
        self.status = status
        self.progress = progress
        self.result = result
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case invalidAPIKey
    case rateLimitExceeded
    case insufficientCredits
    case providerError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .noData:
            return "没有数据返回"
        case .decodingError:
            return "数据解析失败"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .invalidAPIKey:
            return "API密钥无效"
        case .rateLimitExceeded:
            return "API调用频率过高"
        case .insufficientCredits:
            return "API额度不足"
        case .providerError(let message):
            return "提供商错误: \(message)"
        }
    }
}