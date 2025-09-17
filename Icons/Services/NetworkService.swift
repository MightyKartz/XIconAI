//
//  NetworkService.swift
//  Icons
//
//  Created by Icons Team
//

import Foundation
import Combine
import SwiftUI

/// 网络服务管理器
class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    // MARK: - Properties
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var cancellables = Set<AnyCancellable>()
    
    // API配置
    private let baseURL = "https://api.openai.com/v1"
    // NOTE: Do not use direct AppState access here; use await getAPIKey()
    private let apiKeyRemovedDoNotUse = ""
    
    // MARK: - Initialization
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        
        // 配置日期格式
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
    }
    
    // Added: safely read API key from MainActor
    private func getAPIKey() async -> String {
        await MainActor.run { AppState.shared.apiKey }
    }
    
    // MARK: - Public Methods
    
    /// 生成图标
    func generateIcon(
        prompt: String,
        model: String = "dall-e-3",
        size: String = "1024x1024",
        quality: String = "standard"
    ) async throws -> GeneratedIcon {
        let key = await getAPIKey()
        guard !key.isEmpty else {
            throw NetworkError.missingAPIKey
        }
        
        let request = ImageGenerationRequest(
            prompt: prompt,
            model: model,
            size: size,
            quality: quality,
            n: 1,
            responseFormat: "url"
        )
        
        let response: ImageGenerationResponse = try await performRequest(
            endpoint: "/images/generations",
            method: "POST",
            body: request
        )
        
        guard let imageData = response.data.first,
              let imageURL = imageData.url else {
            throw NetworkError.invalidResponse
        }
        
        // 创建生成的图标对象
        let icon = GeneratedIcon(
            prompt: imageData.revisedPrompt ?? prompt,
            imageURL: imageURL,
            size: parseSizeString(size),
            format: "png",
            model: model,
            parameters: [
                "size": size,
                "quality": quality,
                "model": model
            ]
        )
        
        return icon
    }
    
    /// 下载图像到本地
    func downloadImage(from url: String) async throws -> URL {
        guard let imageURL = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await session.data(from: imageURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.downloadFailed
        }
        
        // 创建本地文件路径
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let iconsDirectory = documentsPath.appendingPathComponent("Icons")
        
        // 确保目录存在
        try FileManager.default.createDirectory(at: iconsDirectory, withIntermediateDirectories: true)
        
        let fileName = "icon_\(UUID().uuidString).png"
        let localURL = iconsDirectory.appendingPathComponent(fileName)
        
        // 保存文件
        try data.write(to: localURL)
        
        return localURL
    }
    
    /// 验证API密钥
    func validateAPIKey(_ key: String) async -> Bool {
        do {
            // 通过调用用量接口校验，不修改全局状态
            let _: UsageResponse = try await performGetRequest(
                endpoint: "/usage",
                overrideAPIKey: key
            )
            return true
        } catch {
            return false
        }
    }
    
    /// 获取账户使用情况
    func getUsage() async throws -> UsageInfo {
        let response: UsageResponse = try await performGetRequest(
            endpoint: "/usage"
        )
        
        return UsageInfo(
            totalUsage: response.totalUsage,
            dailyUsage: response.dailyUsage,
            remainingQuota: response.remainingQuota
        )
    }
    
    // MARK: - Private Methods
    
    private func performGetRequest<R: Codable>(
        endpoint: String,
        overrideAPIKey: String? = nil
    ) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // let key = overrideAPIKey ?? await getAPIKey()
        let key: String
        if let override = overrideAPIKey {
            key = override
        } else {
            key = await getAPIKey()
        }
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 检查HTTP状态码
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimited
        case 500...599:
            throw NetworkError.serverError
        default:
            // 尝试解析错误响应
            if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw NetworkError.apiError(apiError.error.message)
            }
            throw NetworkError.unknownError
        }
        
        do {
            return try decoder.decode(R.self, from: data)
        } catch {
            print("解码错误: \(error)")
            print("响应数据: \(String(data: data, encoding: .utf8) ?? "无法解码")")
            throw NetworkError.decodingError
        }
    }
    
    private func performRequest<T: Codable, R: Codable>(
        endpoint: String,
        method: String,
        body: T? = nil,
        overrideAPIKey: String? = nil
    ) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        // let key = overrideAPIKey ?? await getAPIKey()
        let key: String
        if let override = overrideAPIKey {
            key = override
        } else {
            key = await getAPIKey()
        }
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 检查HTTP状态码
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimited
        case 500...599:
            throw NetworkError.serverError
        default:
            // 尝试解析错误响应
            if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw NetworkError.apiError(apiError.error.message)
            }
            throw NetworkError.unknownError
        }
        
        do {
            return try decoder.decode(R.self, from: data)
        } catch {
            print("解码错误: \(error)")
            print("响应数据: \(String(data: data, encoding: .utf8) ?? "无法解码")")
            throw NetworkError.decodingError
        }
    }
    
    private func parseSizeString(_ sizeString: String) -> CGSize {
        let components = sizeString.split(separator: "x")
        guard components.count == 2,
              let width = Double(components[0]),
              let height = Double(components[1]) else {
            return CGSize(width: 1024, height: 1024)
        }
        return CGSize(width: width, height: height)
    }
}

// MARK: - Supporting Types

/// 空请求体
struct EmptyBody: Codable {}

/// 网络错误
enum NetworkError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case unauthorized
    case rateLimited
    case serverError
    case downloadFailed
    case decodingError
    case apiError(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API密钥未设置"
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .unauthorized:
            return "API密钥无效或未授权"
        case .rateLimited:
            return "请求频率过高，请稍后重试"
        case .serverError:
            return "服务器错误，请稍后重试"
        case .downloadFailed:
            return "图像下载失败"
        case .decodingError:
            return "数据解析失败"
        case .apiError(let message):
            return "API错误: \(message)"
        case .unknownError:
            return "未知错误"
        }
    }
}

/// 使用情况信息
struct UsageInfo {
    let totalUsage: Double
    let dailyUsage: Double
    let remainingQuota: Double
}

/// 使用情况响应
struct UsageResponse: Codable {
    let totalUsage: Double
    let dailyUsage: Double
    let remainingQuota: Double
    
    enum CodingKeys: String, CodingKey {
        case totalUsage = "total_usage"
        case dailyUsage = "daily_usage"
        case remainingQuota = "remaining_quota"
    }
}