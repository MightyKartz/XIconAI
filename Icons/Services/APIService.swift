//
//  APIService.swift
//  Icons
//
//  Created by Icons App on 2024/01/15.
//

import Foundation
import Combine
import AppKit

/// API 服务管理器
class APIService: ObservableObject {
    
    static let shared = APIService()
    
    private let session: URLSession
    private var baseURL: URL
    @Published private(set) var baseURLString: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 配置
    
    private struct APIConfig {
        static let baseURL = "https://api.icons-app.com/v1"
        static let timeout: TimeInterval = 30.0
        static let maxRetries = 3
    }
    
    // MARK: - 初始化
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeout
        config.timeoutIntervalForResource = APIConfig.timeout * 2
        
        self.session = URLSession(configuration: config)
        // 调整：支持在 DEBUG 环境使用本地中间层或通过环境变量/用户偏好覆盖
        #if DEBUG
        let envOverride = ProcessInfo.processInfo.environment["ICONS_API_BASE_URL"]
        let userDefaultOverride = UserDefaults.standard.string(forKey: "ICONS_API_BASE_URL")
        // DEBUG模式下默认使用本地开发环境
        let debugDefault = "http://127.0.0.1:8787/v1"
        let baseURLString = (envOverride?.isEmpty == false ? envOverride : nil)
            ?? (userDefaultOverride?.isEmpty == false ? userDefaultOverride : nil)
            ?? debugDefault
        #else
        let baseURLString = APIConfig.baseURL
        #endif
        self.baseURL = URL(string: baseURLString)!
        self.baseURLString = self.baseURL.absoluteString
    }
    
    // MARK: - 图标生成 API（旧，逐步迁移）
    
    /// 生成图标（旧版直连端点，保留以兼容，后续迁移到中间层）
    func generateIcon(prompt: String, style: String? = nil, parameters: [String: Any] = [:]) async throws -> GeneratedIcon {
        let endpoint = "/icons/generate"
        
        var requestBody: [String: Any] = [
            "prompt": prompt,
            "parameters": parameters
        ]
        
        if let style = style {
            requestBody["style"] = style
        }
        
        let response: IconGenerationResponse = try await performRequest(
            endpoint: endpoint,
            method: .POST,
            body: requestBody
        )
        
        return try await downloadAndCreateIcon(from: response)
    }
    
    /// 批量生成图标（旧版直连端点，保留以兼容）
    func generateIcons(requests: [IconGenerationRequest]) async throws -> [GeneratedIcon] {
        let endpoint = "/icons/batch-generate"
        
        let requestBody = [
            "requests": requests.map { request in
                [
                    "prompt": request.prompt,
                    "style": request.style as Any,
                    "parameters": request.parameters
                ]
            }
        ]
        
        let response: BatchIconGenerationResponse = try await performRequest(
            endpoint: endpoint,
            method: .POST,
            body: requestBody
        )
        
        var icons: [GeneratedIcon] = []
        for iconResponse in response.icons {
            let icon = try await downloadAndCreateIcon(from: iconResponse)
            icons.append(icon)
        }
        
        return icons
    }
    
    /// 获取生成状态（旧版直连端点，保留以兼容）
    func getGenerationStatus(taskId: String) async throws -> GenerationStatus {
        let endpoint = "/icons/status/\(taskId)"
        
        let response: GenerationStatusResponse = try await performRequest(
            endpoint: endpoint,
            method: .GET
        )
        
        return GenerationStatus(
            taskId: response.taskId,
            status: GenerationStatus.Status(rawValue: response.status) ?? .pending,
            progress: response.progress,
            estimatedTimeRemaining: response.estimatedTimeRemaining,
            resultURL: response.resultURL
        )
    }
    
    // MARK: - 模板 API
    
    /// 获取云端模板
    func fetchCloudTemplates(category: String? = nil, page: Int = 1, limit: Int = 20) async throws -> TemplateListResponse {
        var endpoint = "/templates?page=\(page)&limit=\(limit)"
        
        if let category = category {
            endpoint += "&category=\(category)"
        }
        
        return try await performRequest(endpoint: endpoint, method: .GET)
    }
    
    /// 上传用户模板
    func uploadTemplate(_ template: PromptTemplate) async throws -> TemplateUploadResponse {
        let endpoint = "/templates"
        
        let requestBody: [String: Any] = [
            "name": template.name,
            "description": template.description,
            "category": template.category.rawValue,
            "prompt": template.content,
            "parameters": template.parameters.map { param in
                [
                    "name": param.name,
                    "type": param.type.rawValue,
                    "defaultValue": param.defaultValue as Any,
                    "options": param.options as Any,
                    "required": param.isRequired
                ]
            },
            "tags": template.tags,
            "isPublic": false
        ]
        
        return try await performRequest(
            endpoint: endpoint,
            method: .POST,
            body: requestBody
        )
    }
    
    /// 同步用户模板
    func syncUserTemplates() async throws -> [PromptTemplate] {
        let endpoint = "/templates/user"
        
        let response: UserTemplatesResponse = try await performRequest(
            endpoint: endpoint,
            method: .GET
        )
        
        return response.templates.map { templateData in
            PromptTemplate(
                id: UUID(uuidString: templateData.id) ?? UUID(),
                name: templateData.name,
                category: TemplateCategory(rawValue: templateData.category) ?? .modern,
                content: templateData.prompt,
                description: templateData.description,
                tags: templateData.tags,
                parameters: templateData.parameters.map { paramData in
                    TemplateParameter(
                        name: paramData.name,
                        displayName: paramData.name.capitalized,
                        type: ParameterType(rawValue: paramData.type) ?? .text,
                        defaultValue: paramData.defaultValue?.value as? String ?? "",
                        isRequired: paramData.required,
                        options: paramData.options?.compactMap { $0.value as? String }
                    )
                },
                createdAt: ISO8601DateFormatter().date(from: templateData.createdAt) ?? Date(),
                updatedAt: ISO8601DateFormatter().date(from: templateData.updatedAt) ?? Date(),
                isBuiltIn: false
            )
        }
    }
    
    // MARK: - 用户 API
    
    /// 用户认证
    func authenticate(token: String) async throws -> UserProfile {
        let endpoint = "/auth/verify"
        
        let response: AuthResponse = try await performRequest(
            endpoint: endpoint,
            method: .POST,
            headers: ["Authorization": "Bearer \(token)"]
        )
        
        return UserProfile(
            id: response.user.id,
            email: response.user.email,
            name: response.user.name,
            avatarURL: response.user.avatarURL,
            subscription: UserSubscription(
                type: UserSubscription.SubscriptionType(rawValue: response.user.subscription.type) ?? .free,
                expiresAt: response.user.subscription.expiresAt.flatMap { ISO8601DateFormatter().date(from: $0) },
                features: response.user.subscription.features
            ),
            usage: UserUsage(
                iconsGenerated: response.user.usage.iconsGenerated,
                iconsLimit: response.user.usage.iconsLimit,
                templatesCreated: response.user.usage.templatesCreated,
                templatesLimit: response.user.usage.templatesLimit
            )
        )
    }
    
    /// 获取用户使用统计（旧）
    func getUserUsage() async throws -> UserUsage {
        let endpoint = "/user/usage"
        
        let response: UserUsageResponse = try await performRequest(
            endpoint: endpoint,
            method: .GET
        )
        
        return UserUsage(
            iconsGenerated: response.iconsGenerated,
            iconsLimit: response.iconsLimit,
            templatesCreated: response.templatesCreated,
            templatesLimit: response.templatesLimit
        )
    }
    
    // MARK: - 中间层 API（新）
    
    /// 获取配额信息（替代本地/厂商直连的剩余额度读取）
    func getQuota() async throws -> QuotaResponse {
        // 始终从后端获取真实的配额信息，确保与API调用保持一致
        return try await performRequest(endpoint: "/quota", method: .GET)
    }
    
    /// 校验收据并同步订阅
    func verifyReceipt(_ receiptData: Data) async throws -> ReceiptVerifyResponse {
        let body: [String: Any] = ["receipt": receiptData.base64EncodedString()]
        return try await performRequest(endpoint: "/receipt/verify", method: .POST, body: body)
    }
    
    /// 创建生成任务（POST /v1/generate）
    func createGenerationTask(prompt: String, style: String? = nil, parameters: [String: Any] = [:]) async throws -> String {
        var body: [String: Any] = [
            "prompt": prompt,
            "parameters": parameters
        ]
        if let style = style {
            body["style"] = style
            print("=== Creating Generation Task ===")
            print("Creating generation task with style: \(style)")
            // Try to get more detailed information about the style
            if let iconStyle = IconStyle(rawValue: style) {
                print("Style display name: \(iconStyle.displayName)")
                print("Style category: \(iconStyle.category.displayName)")
                print("Style description: \(iconStyle.description)")
                print("Style recommended use: \(iconStyle.recommendedUse.joined(separator: ", "))")
                print("Style suggested colors: \(iconStyle.suggestedColors.joined(separator: ", "))")
                print("Style prompt modifier: \(iconStyle.promptModifier)")
            }
        } else {
            print("Creating generation task without specific style")
        }

        // Log parameters
        print("Generation parameters:")
        for (key, value) in parameters {
            print("  \(key): \(value)")
        }

        let resp: GenerateTaskResponse = try await performRequest(endpoint: "/generate", method: .POST, body: body)
        print("Generation task created with ID: \(resp.taskId)")
        return resp.taskId
    }
    
    /// 查询任务状态（GET /v1/task/{id}）
    func getTaskStatus(taskId: String) async throws -> TaskStatusResponse {
        return try await performRequest(endpoint: "/task/\(taskId)", method: .GET)
    }
    
    /// 下载图片并创建 GeneratedIcon（基于中间层任务结果）
    func downloadImageAndCreateIcon(imageURL: String, prompt: String, style: String? = nil, parameters: [String: Any] = [:]) async throws -> GeneratedIcon {
        print("Creating GeneratedIcon with style: \(style ?? "none")")
        print("Prompt: \(prompt)")
        print("Image URL: \(imageURL)")

        guard let url = URL(string: imageURL) else { throw APIError.invalidImageURL }
        let (data, _) = try await session.data(from: url)
        guard let image = NSImage(data: data) else { throw APIError.invalidImageData }

        // Log image information
        print("Downloaded image size: \(image.size.width)x\(image.size.height)")

        // Prepare tags with style and symbols information
        var tags: [String] = []

        // Explicitly handle the style parameter to ensure it's correctly added to tags
        // This is critical for proper style display in the UI
        if let iconStyleRawValue = style {
            tags.append(iconStyleRawValue)
            print("Added style tag: \(iconStyleRawValue)")
        }

        // Add symbols to tags if present in parameters
        if let symbolsParam = parameters["symbols"] as? String, !symbolsParam.isEmpty {
            let symbolTags = symbolsParam.split(separator: ",").map { "symbol:\($0.trimmingCharacters(in: .whitespaces))" }
            tags.append(contentsOf: symbolTags)
            print("Added symbol tags: \(symbolTags)")
        } else if let symbolsArray = parameters["symbols"] as? [String], !symbolsArray.isEmpty {
            let symbolTags = symbolsArray.map { "symbol:\($0)" }
            tags.append(contentsOf: symbolTags)
            print("Added symbol tags: \(symbolTags)")
        }

        // Also ensure the style is explicitly stored in parameters for consistency
        // This helps with export and other features that might need style info
        var iconParameters = parameters.reduce(into: [String: String]()) { acc, kv in acc[kv.key] = String(describing: kv.value) }
        if let iconStyleRawValue = style {
            iconParameters["style"] = iconStyleRawValue
            print("=== Creating GeneratedIcon ===")
            print("Stored style in parameters: \(iconStyleRawValue)")
            // Try to get more detailed information about the style
            if let iconStyle = IconStyle(rawValue: iconStyleRawValue) {
                print("Style display name: \(iconStyle.displayName)")
                print("Style category: \(iconStyle.category.displayName)")
                print("Style description: \(iconStyle.description)")
                print("Style recommended use: \(iconStyle.recommendedUse.joined(separator: ", "))")
                print("Style suggested colors: \(iconStyle.suggestedColors.joined(separator: ", "))")
            }
        }

        // Log all parameters
        print("Icon parameters:")
        for (key, value) in iconParameters {
            print("  \(key): \(value)")
        }

        let generatedIcon = GeneratedIcon(
            id: UUID(),
            prompt: prompt,
            templateId: nil,
            imageURL: imageURL,
            localPath: nil,
            size: image.size,
            format: "PNG",
            createdAt: Date(),
            model: "api",
            parameters: iconParameters,
            isFavorite: false,
            tags: tags
        )

        print("GeneratedIcon created successfully with ID: \(generatedIcon.id)")
        return generatedIcon
    }
    
    // MARK: - 核心网络方法
    
    /// 执行 HTTP 请求
    private func performRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: [String: Any]? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        // URL 拼接：兼容以 / 开头的端点和带查询参数的字符串
        let url: URL
        if endpoint.lowercased().hasPrefix("http://") || endpoint.lowercased().hasPrefix("https://") {
            guard let absURL = URL(string: endpoint) else { throw APIError.invalidURL }
            url = absURL
        } else {
            var base = baseURL.absoluteString
            if base.hasSuffix("/") { base.removeLast() }
            var path = endpoint
            if path.hasPrefix("/") { path.removeFirst() }
            let urlString = base + "/" + path
            guard let composed = URL(string: urlString) else { throw APIError.invalidURL }
            url = composed
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // 设置默认头部
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Icons-App/1.0", forHTTPHeaderField: "User-Agent")
        
        // 添加自定义头部
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // DEBUG: 按需注入开发者请求头（仅在启用开发者功能时）
        #if DEBUG
        let defaults = UserDefaults.standard
        let freeUnlimitedUsage = defaults.bool(forKey: "freeUnlimitedUsage")
        let isProUser = defaults.bool(forKey: "isProUser")
        
        // 在 DEBUG 下：当 isProUser 或 freeUnlimitedUsage 任一为真时，注入开发者请求头
        if isProUser || freeUnlimitedUsage {
            // 生成或获取设备UUID作为用户ID（以 dev- 前缀启用后端开发者绕过）
            var userId: String
            if let existing = defaults.string(forKey: "devDeviceUUID"), !existing.isEmpty {
                userId = existing
            } else {
                let newId = "dev-" + UUID().uuidString
                defaults.set(newId, forKey: "devDeviceUUID")
                userId = newId
            }
            
            // 根据开关决定计划：Pro 开启则走 pro，免费无限次则走 free（并触发后端开发者绕过）
            let plan = isProUser ? "pro" : "free"
            
            request.setValue(userId, forHTTPHeaderField: "X-User-Id")
            request.setValue(plan, forHTTPHeaderField: "X-Plan")
            
            // 对于任务轮询等高频请求，抑制日志噪声
            let isTaskPolling = endpoint.hasPrefix("/task/")
            if !isTaskPolling {
                let reason = isProUser ? "isProUser" : "freeUnlimitedUsage"
                print("🔧 [Developer] Injected headers → X-User-Id=\(userId) X-Plan=\(plan) (reason: \(reason))")
            }
        }
        #endif
        
        // 设置请求体
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        // 执行请求（增加网络错误映射）
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            if let urlError = error as? URLError {
                let host = (request.url?.host).map { " \($0)" } ?? ""
                switch urlError.code {
                case .cannotFindHost, .dnsLookupFailed:
                    throw APIError.serverError(code: urlError.errorCode, message: "无法解析服务器地址\(host)。请在设置中检查 API 基础地址：\(baseURL.absoluteString)")
                case .cannotConnectToHost:
                    throw APIError.serverError(code: urlError.errorCode, message: "无法连接到服务器\(host)。可能服务未启动或被防火墙阻止。")
                case .notConnectedToInternet:
                    throw APIError.serverError(code: urlError.errorCode, message: "当前无网络连接，请检查网络设置后重试。")
                case .timedOut:
                    throw APIError.serverError(code: urlError.errorCode, message: "请求超时，请稍后重试。")
                default:
                    // 统一兜底中文消息
                    throw APIError.serverError(code: urlError.errorCode, message: "网络请求失败（\(urlError.code.rawValue)），请稍后重试。")
                }
            }
            throw APIError.networkError(error)
        }
        
        // 检查响应状态
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            // 特殊错误码映射
            if httpResponse.statusCode == 401 {
                print("API Error: Authentication required (401)")
                throw APIError.authenticationRequired
            }
            if httpResponse.statusCode == 429 {
                print("API Error: Rate limit exceeded (429)")
                throw APIError.rateLimitExceeded
            }
            if httpResponse.statusCode == 402 {
                print("API Error: Quota exceeded (402)")
                throw APIError.quotaExceeded
            }
            print("API Error: Server error (\(httpResponse.statusCode)): \(errorResponse?.message ?? "Unknown error")")
            throw APIError.serverError(
                code: httpResponse.statusCode,
                message: errorResponse?.message ?? "Unknown error"
            )
        }
        
        // 解析响应数据
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            // 尽可能提供中文可读信息
            throw APIError.decodingError(error)
        }
    }
    
    /// 下载图像并创建图标（旧）
    private func downloadAndCreateIcon(from response: IconGenerationResponse) async throws -> GeneratedIcon {
        guard let imageURL = URL(string: response.imageURL) else {
            throw APIError.invalidImageURL
        }
        
        let (data, _) = try await session.data(from: imageURL)
        
        guard let image = NSImage(data: data) else {
            throw APIError.invalidImageData
        }
        
        return GeneratedIcon(
            id: UUID(uuidString: response.id) ?? UUID(),
            prompt: response.prompt,
            templateId: nil,
            imageURL: response.imageURL,
            localPath: nil,
            size: image.size,
            format: "PNG",
            createdAt: ISO8601DateFormatter().date(from: response.createdAt) ?? Date(),
            model: "api",
            parameters: response.parameters.mapValues { $0.value as? String ?? "" },
            isFavorite: false,
            tags: response.style.map { [$0] } ?? []
        )
    }
    
    // MARK: - 运行时更新基础地址（仅用于调试/配置）
    /// 设置/覆盖基础地址（传入 nil 或空字符串表示清除覆盖，恢复默认逻辑）
    func setBaseURLOverride(_ override: String?) {
        let trimmed = override?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let s = trimmed, !s.isEmpty, let url = URL(string: s) {
            UserDefaults.standard.set(s, forKey: "ICONS_API_BASE_URL")
            self.baseURL = url
            self.baseURLString = url.absoluteString
            return
        }
        // 清除覆盖，恢复默认
        UserDefaults.standard.removeObject(forKey: "ICONS_API_BASE_URL")
        #if DEBUG
        let envOverride = ProcessInfo.processInfo.environment["ICONS_API_BASE_URL"]
        let debugDefault = "http://127.0.0.1:8787/v1"
        let baseURLString = (envOverride?.isEmpty == false ? envOverride : nil) ?? debugDefault
        #else
        let baseURLString = APIConfig.baseURL
        #endif
        let url = URL(string: baseURLString)!
        self.baseURL = url
        self.baseURLString = url.absoluteString
    }
    // 新增：健康检查（带覆盖地址，用于不保存临时测试）
    func healthCheck(overrideBaseURL: String?) async throws -> HealthResponse {
        var base = (overrideBaseURL?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }
            ?? baseURL.absoluteString
        if base.hasSuffix("/v1") {
            base = String(base.dropLast(3))
        }
        let healthURL = base + "/health"
        let resp: HealthResponse = try await performRequest(endpoint: healthURL, method: .GET)
        return resp
    }
}

// MARK: - 数据模型

/// HTTP 方法
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

/// API 错误
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidImageURL
    case invalidImageData
    case networkError(Error)
    case serverError(code: Int, message: String)
    case decodingError(Error)
    case authenticationRequired
    case rateLimitExceeded
    case quotaExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .invalidResponse:
            return "无效的响应"
        case .invalidImageURL:
            return "无效的图像 URL"
        case .invalidImageData:
            return "无效的图像数据"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "服务器错误 (\(code)): \(message)"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .authenticationRequired:
            return "需要用户认证"
        case .rateLimitExceeded:
            return "请求频率超限"
        case .quotaExceeded:
            return "使用配额已用完"
        }
    }
}

/// 图标生成请求
struct IconGenerationRequest {
    let prompt: String
    let style: String?
    let parameters: [String: Any]
}

/// 生成状态
struct GenerationStatus {
    let taskId: String
    let status: Status
    let progress: Double
    let estimatedTimeRemaining: TimeInterval?
    let resultURL: String?
    
    enum Status: String, Codable {
        case pending = "pending"
        case processing = "processing"
        case completed = "completed"
        case failed = "failed"
        case cancelled = "cancelled"
    }
}

/// 用户资料
struct UserProfile {
    let id: String
    let email: String
    let name: String
    let avatarURL: String?
    let subscription: UserSubscription
    let usage: UserUsage
}

/// 用户订阅
struct UserSubscription {
    let type: SubscriptionType
    let expiresAt: Date?
    let features: [String]
    
    enum SubscriptionType: String, Codable {
        case free = "free"
        case pro = "pro"
        case enterprise = "enterprise"
    }
}

/// 用户使用情况
struct UserUsage {
    let iconsGenerated: Int
    let iconsLimit: Int
    let templatesCreated: Int
    let templatesLimit: Int
    
    var iconsRemaining: Int {
        return max(0, iconsLimit - iconsGenerated)
    }
    
    var templatesRemaining: Int {
        return max(0, templatesLimit - templatesCreated)
    }
    
    var isIconLimitReached: Bool {
        return iconsGenerated >= iconsLimit
    }
    
    var isTemplateLimitReached: Bool {
        return templatesCreated >= templatesLimit
    }
}

// MARK: - API 响应模型（旧）

/// 图标生成响应
struct IconGenerationResponse: Codable {
    let id: String
    let prompt: String
    let style: String?
    let parameters: [String: AnyCodable]
    let imageURL: String
    let createdAt: String
}

/// 批量图标生成响应
struct BatchIconGenerationResponse: Codable {
    let icons: [IconGenerationResponse]
}

/// 生成状态响应（旧）
struct GenerationStatusResponse: Codable {
    let taskId: String
    let status: String
    let progress: Double
    let estimatedTimeRemaining: TimeInterval?
    let resultURL: String?
}

// MARK: - 中间层 API 响应模型（新）

struct QuotaResponse: Codable {
    let remaining: Int
    let plan: String
    let limit: Int?
    let resetAt: String?
}

struct GenerateTaskResponse: Codable {
    let taskId: String
}

struct TaskStatusResponse: Codable {
    let taskId: String
    let status: String
    let progress: Double?
    let resultURL: String?
    let error: String?
}

struct ReceiptVerifyResponse: Codable {
    let success: Bool
    let plan: String?
    let expiresAt: String?
}

struct TemplateListResponse: Codable {
    let templates: [TemplateData]
    let totalCount: Int
    let page: Int
    let limit: Int
    let hasMore: Bool
}

struct TemplateData: Codable {
    let id: String
    let name: String
    let description: String
    let category: String
    let prompt: String
    let parameters: [ParameterData]
    let tags: [String]
    let createdAt: String
    let updatedAt: String
}

struct ParameterData: Codable {
    let name: String
    let type: String
    let defaultValue: AnyCodable?
    let options: [AnyCodable]?
    let required: Bool
}

struct TemplateUploadResponse: Codable {
    let id: String
    let message: String
}

struct UserTemplatesResponse: Codable {
    let templates: [TemplateData]
}

struct AuthResponse: Codable {
    let user: UserData
    let token: String
}

struct UserData: Codable {
    let id: String
    let email: String
    let name: String
    let avatarURL: String?
    let subscription: SubscriptionData
    let usage: UsageData
}

struct SubscriptionData: Codable {
    let type: String
    let expiresAt: String?
    let features: [String]
}

struct UsageData: Codable {
    let iconsGenerated: Int
    let iconsLimit: Int
    let templatesCreated: Int
    let templatesLimit: Int
}

struct UserUsageResponse: Codable {
    let iconsGenerated: Int
    let iconsLimit: Int
    let templatesCreated: Int
    let templatesLimit: Int
}

struct ErrorResponse: Codable {
    let error: String
    let message: String
    let code: Int?
}

struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value as Any
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if container.decodeNil() {
            value = NSNull()
        } else {
            // 尝试解码为字典或数组
            if let dictValue = try? container.decode([String: AnyCodable].self) {
                value = dictValue.mapValues { $0.value }
            } else if let arrayValue = try? container.decode([AnyCodable].self) {
                value = arrayValue.map { $0.value }
            } else {
                value = NSNull()
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let v as Int:
            try container.encode(v)
        case let v as Double:
            try container.encode(v)
        case let v as Bool:
            try container.encode(v)
        case let v as String:
            try container.encode(v)
        case _ as NSNull:
            try container.encodeNil()
        case let v as [String: Any]:
            let wrapped = v.mapValues { AnyCodable($0) }
            try container.encode(wrapped)
        case let v as [Any]:
            let wrapped = v.map { AnyCodable($0) }
            try container.encode(wrapped)
        default:
            // 不支持的类型，降级为字符串
            try container.encode(String(describing: value))
        }
    }
}
struct HealthResponse: Codable {
    let ok: Bool
    let time: String
}