//
//  AIGenerationService.swift
//  Icons
//
//  Created by Icons App on 2024/01/15.
//

import Foundation
import AppKit
import Combine

// 为所有错误提供统一的中文用户可读消息
extension Error {
    var iconsUserMessage: String {
        if let localized = (self as? LocalizedError)?.errorDescription, !localized.isEmpty {
            return localized
        }
        if let urlError = self as? URLError {
            switch urlError.code {
            case .cannotFindHost, .dnsLookupFailed:
                return "无法解析服务器地址，请检查设置中的 API 基础地址或网络 DNS。"
            case .cannotConnectToHost:
                return "无法连接到服务器，可能服务未启动或被防火墙/代理阻止。"
            case .notConnectedToInternet:
                return "当前无网络连接，请检查网络后重试。"
            case .timedOut:
                return "请求超时，请稍后重试。"
            default:
                break
            }
        }
        return self.localizedDescription
    }
}

/// AI 图标生成服务
class AIGenerationService: ObservableObject {
    
    static let shared = AIGenerationService()
    
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var currentTask: String = ""
    
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    private var currentGenerationTask: Task<Void, Never>?
    
    // MARK: - AI 服务提供商配置
    
    private struct AIProviders {
        static let openAI = "https://api.openai.com/v1"
        static let stability = "https://api.stability.ai/v1"
        static let midjourney = "https://api.midjourney.com/v1"
        static let replicate = "https://api.replicate.com/v1"
    }
    
    // MARK: - 初始化
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60.0
        config.timeoutIntervalForResource = 300.0
        
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - 公共生成方法
    
    /// 生成单个图标
    func generateIcon(
        prompt: String,
        style: IconStyle = .minimalist,
        parameters: GenerationParameters = GenerationParameters()
    ) async throws -> GeneratedIcon {
        // Log detailed style information
        print("Starting icon generation with style: \(style.rawValue)")
        print("Style display name: \(style.displayName)")
        print("Style category: \(style.category.displayName)")
        print("Style description: \(style.description)")
        print("Style recommended use: \(style.recommendedUse.joined(separator: ", "))")
        print("Style suggested colors: \(style.suggestedColors.joined(separator: ", "))")
        print("Style prompt modifier: \(style.promptModifier)")

        await MainActor.run {
            isGenerating = true
            generationProgress = 0.0
            currentTask = "准备生成图标..."
        }
        
        defer {
            Task { @MainActor in
                isGenerating = false
                generationProgress = 0.0
                currentTask = ""
            }
        }
        
        do {
            // 预检查配额（友好提示，而非强制依赖）
            await MainActor.run {
                generationProgress = 0.05
                currentTask = "检查配额..."
            }
            do {
                let quota = try await APIService.shared.getQuota()
                print("=== Quota Check ===")
                print("Remaining: \(quota.remaining)")
                print("Plan: \(quota.plan)")
                print("Limit: \(quota.limit ?? -1)")

                #if DEBUG
                // 检查开发者测试选项
                let userDefaults = UserDefaults.standard
                let freeUnlimitedUsage = userDefaults.bool(forKey: "freeUnlimitedUsage")
                let isProUser = userDefaults.bool(forKey: "isProUser")
                
                if freeUnlimitedUsage {
                    print("🔧 [Developer] Free unlimited usage enabled - bypassing quota check")
                    print("Quota available - continuing with generation (developer mode)")
                } else if isProUser {
                    print("🔧 [Developer] Pro user mode enabled - bypassing quota check")
                    print("Quota available - continuing with generation (developer pro mode)")
                } else {
                    // 正常配额检查
                    if quota.remaining <= 0 {
                        print("Quota exceeded - throwing error")
                        throw AIGenerationError.quotaExceeded
                    }
                    print("Quota available - continuing with generation")
                }
                #else
                // Release模式下始终检查真实的配额状态
                if quota.remaining <= 0 {
                    print("Quota exceeded - throwing error")
                    throw AIGenerationError.quotaExceeded
                }
                print("Quota available - continuing with generation")
                #endif
            } catch {
                #if DEBUG
                // 在DEBUG模式下，如果启用了开发者选项，即使配额检查失败也继续
                let userDefaults = UserDefaults.standard
                let freeUnlimitedUsage = userDefaults.bool(forKey: "freeUnlimitedUsage")
                let isProUser = userDefaults.bool(forKey: "isProUser")
                
                if freeUnlimitedUsage || isProUser {
                    print("🔧 [Developer] Quota check failed but developer mode enabled - continuing anyway")
                } else {
                    print("Quota check failed: \(error)")
                    throw error
                }
                #else
                // Release模式下，配额检查失败则抛出错误
                print("Quota check failed: \(error)")
                throw error
                #endif
            }
            
            // 优化提示词
            await MainActor.run {
                generationProgress = 0.12
                currentTask = "优化提示词..."
            }
            let optimizedPrompt = try await optimizePrompt(prompt, style: style, parameters: parameters)
            
            // 创建生成任务
            await MainActor.run {
                generationProgress = 0.2
                currentTask = "创建生成任务..."
            }
            let taskId = try await APIService.shared.createGenerationTask(
                prompt: optimizedPrompt,
                style: style.rawValue,
                parameters: parameters.toDictionary()
            )
            
            // 轮询任务状态
            await MainActor.run {
                currentTask = "排队/生成中..."
            }
            var icon: GeneratedIcon?
            var progressHint: Double = 0.25
            while true {
                try Task.checkCancellation()
                let status = try await APIService.shared.getTaskStatus(taskId: taskId)

                // 映射进度到 0.25 ~ 0.9 区间
                let p = status.progress ?? 0.0
                let mapped = 0.25 + min(max(p, 0.0), 1.0) * 0.65
                let currentProgressHint = progressHint
                await MainActor.run {
                    generationProgress = max(currentProgressHint, mapped)
                    switch status.status.lowercased() {
                    case "pending": currentTask = "排队中..."
                    case "processing": currentTask = "正在生成图像..."
                    case "completed": currentTask = "下载图像..."
                    case "failed": currentTask = "生成失败"
                    default: currentTask = "处理中..."
                    }
                }

                if status.status.lowercased() == "completed" {
                    guard let url = status.resultURL else {
                        throw AIGenerationError.invalidResponse
                    }
                    icon = try await APIService.shared.downloadImageAndCreateIcon(
                        imageURL: url,
                        prompt: prompt,
                        style: style.rawValue,
                        parameters: parameters.toDictionary()
                    )
                    break
                }
                if status.status.lowercased() == "failed" {
                    throw AIGenerationError.generationFailed(status.error ?? "unknown")
                }

                // 间隔轮询
                try await Task.sleep(nanoseconds: 350_000_000) // 0.35s
                progressHint = min(0.85, progressHint + 0.03)
            }
            
            guard let result = icon else { throw AIGenerationError.invalidResponse }
            await MainActor.run {
                generationProgress = 1.0
                currentTask = "完成"
            }
            return result
            
        } catch {
            await MainActor.run {
                currentTask = "生成失败: \(error.iconsUserMessage)"
            }
            throw error
        }
    }
    
    /// 批量生成图标
    func generateIcons(
        prompts: [String],
        style: IconStyle = .minimalist,
        parameters: GenerationParameters = GenerationParameters(),
        progressHandler: @escaping (Double, String) -> Void = { _, _ in }
    ) async throws -> [GeneratedIcon] {
        // Log detailed style information for batch generation
        print("=== Starting batch icon generation ===")
        print("Batch generation with style: \(style.rawValue)")
        print("Style display name: \(style.displayName)")
        print("Style category: \(style.category.displayName)")
        print("Style description: \(style.description)")
        print("Style recommended use: \(style.recommendedUse.joined(separator: ", "))")
        print("Style suggested colors: \(style.suggestedColors.joined(separator: ", "))")
        print("Style prompt modifier: \(style.promptModifier)")
        print("Batch size: \(prompts.count)")

        await MainActor.run {
            isGenerating = true
            generationProgress = 0.0
        }
        
        defer {
            Task { @MainActor in
                isGenerating = false
                generationProgress = 0.0
                currentTask = ""
            }
        }
        
        var icons: [GeneratedIcon] = []
        let totalCount = max(1, prompts.count)
        
        for (index, prompt) in prompts.enumerated() {
            let baseProgress = Double(index) / Double(totalCount)
            await MainActor.run {
                generationProgress = baseProgress
                currentTask = "生成图标 \(index + 1)/\(totalCount)"
            }
            progressHandler(baseProgress, "生成图标 \(index + 1)/\(totalCount)")
            do {
                let icon = try await generateIcon(prompt: prompt, style: style, parameters: parameters)
                icons.append(icon)
            } catch {
                // 不中断批量
                print("生成图标失败: \(prompt) - \(error)")
            }
        }
        
        await MainActor.run {
            generationProgress = 1.0
            currentTask = "批量生成完成"
        }
        
        return icons
    }
    
    /// 取消当前生成任务
    func cancelGeneration() {
        currentGenerationTask?.cancel()
        currentGenerationTask = nil
        
        Task { @MainActor in
            isGenerating = false
            generationProgress = 0.0
            currentTask = "已取消"
        }
    }
    
    // MARK: - 私有方法
    
    /// 选择最佳的 AI 服务提供商
    private func selectBestProvider(for style: IconStyle, parameters: GenerationParameters) -> AIProvider {
        // 根据风格和参数选择最适合的 AI 服务
        switch style {
        case .realistic:
            return .stability // Stability AI 擅长真实感图像
        case .watercolor, .sketch:
            return .midjourney // Midjourney 擅长艺术风格
        case .minimalist, .flat:
            return .openAI // DALL-E 擅长简洁现代风格
        case .geometric:
            return .replicate // Replicate 有专门的 3D 模型
        default:
            return .openAI // 默认使用 OpenAI
        }
    }
    
    // 读取不同供应商的 API Key（开发期从环境变量，生产需走后端中间层获取临时令牌）
    private func getAPIKey(for provider: AIProvider) -> String {
        let env = ProcessInfo.processInfo.environment
        switch provider {
        case .openAI:
            return env["OPENAI_API_KEY"] ?? ""
        case .stability:
            return env["STABILITY_API_KEY"] ?? ""
        case .midjourney:
            return env["MIDJOURNEY_API_KEY"] ?? ""
        case .replicate:
            return env["REPLICATE_API_TOKEN"] ?? ""
        }
    }
    
    /// 优化提示词
    private func optimizePrompt(
        _ prompt: String,
        style: IconStyle,
        parameters: GenerationParameters
    ) async throws -> String {
        var optimizedPrompt = prompt

        // Log the original prompt and style being used
        print("Optimizing prompt for style: \(style.rawValue) - \(style.displayName)")
        print("Original prompt: \(prompt)")

        // 添加图标特定的描述
        optimizedPrompt += ", icon design"

        // 添加风格描述
        let styleModifier = style.promptModifier
        optimizedPrompt += ", \(styleModifier)"
        print("Added style modifier: \(styleModifier)")

        // 添加技术要求
        optimizedPrompt += ", high resolution, transparent background, centered composition"

        // 添加颜色要求
        if let colorScheme = parameters.colorScheme {
            optimizedPrompt += ", \(colorScheme) color scheme"
            print("Added color scheme: \(colorScheme)")
        }

        // 添加尺寸要求
        optimizedPrompt += ", square aspect ratio, \(parameters.size)x\(parameters.size) pixels"
        print("Added size requirement: \(parameters.size)x\(parameters.size) pixels")

        // Log the final optimized prompt
        print("Final optimized prompt: \(optimizedPrompt)")

        return optimizedPrompt
    }
    
    /// 使用指定提供商生成图像
    private func generateWithProvider(
        _ provider: AIProvider,
        prompt: String,
        parameters: GenerationParameters
    ) async throws -> Data {
        switch provider {
        case .openAI:
            return try await generateWithOpenAI(prompt: prompt, parameters: parameters)
        case .stability:
            return try await generateWithStability(prompt: prompt, parameters: parameters)
        case .midjourney:
            return try await generateWithMidjourney(prompt: prompt, parameters: parameters)
        case .replicate:
            return try await generateWithReplicate(prompt: prompt, parameters: parameters)
        }
    }
    
    /// OpenAI DALL-E 生成
    private func generateWithOpenAI(prompt: String, parameters: GenerationParameters) async throws -> Data {
        let url = URL(string: "\(AIProviders.openAI)/images/generations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getAPIKey(for: .openAI))", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "size": "\(parameters.size)x\(parameters.size)",
            "quality": parameters.quality.rawValue,
            "response_format": "b64_json"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw AIGenerationError.apiError("OpenAI API request failed")
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let dataArray = jsonResponse?["data"] as? [[String: Any]],
              let firstImage = dataArray.first,
              let b64String = firstImage["b64_json"] as? String,
              let imageData = Data(base64Encoded: b64String) else {
            throw AIGenerationError.invalidResponse
        }
        
        return imageData
    }
    
    /// Stability AI 生成
    private func generateWithStability(prompt: String, parameters: GenerationParameters) async throws -> Data {
        let url = URL(string: "\(AIProviders.stability)/generation/stable-diffusion-xl-1024-v1-0/text-to-image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(getAPIKey(for: .stability), forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "text_prompts": [
                ["text": prompt, "weight": 1.0]
            ],
            "cfg_scale": parameters.cfgScale,
            "height": parameters.size,
            "width": parameters.size,
            "samples": 1,
            "steps": parameters.steps
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw AIGenerationError.apiError("Stability AI request failed")
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let artifacts = jsonResponse?["artifacts"] as? [[String: Any]],
              let firstArtifact = artifacts.first,
              let b64String = firstArtifact["base64"] as? String,
              let imageData = Data(base64Encoded: b64String) else {
            throw AIGenerationError.invalidResponse
        }
        
        return imageData
    }
    
    /// Midjourney 生成（模拟实现）
    private func generateWithMidjourney(prompt: String, parameters: GenerationParameters) async throws -> Data {
        // 注意：Midjourney 没有直接的 API，这里是模拟实现
        // 实际应用中可能需要使用第三方服务或等待官方 API
        throw AIGenerationError.providerNotAvailable("Midjourney API not available")
    }
    
    /// Replicate 生成
    private func generateWithReplicate(prompt: String, parameters: GenerationParameters) async throws -> Data {
        let url = URL(string: "\(AIProviders.replicate)/predictions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token \(getAPIKey(for: .replicate))", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "version": "ac732df83cea7fff18b8472768c88ad041fa750ff7682a21affe81863cbe77e4", // SDXL
            "input": [
                "prompt": prompt,
                "width": parameters.size,
                "height": parameters.size,
                "num_inference_steps": parameters.steps,
                "guidance_scale": parameters.cfgScale
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw AIGenerationError.apiError("Replicate API request failed")
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let predictionId = jsonResponse?["id"] as? String else {
            throw AIGenerationError.invalidResponse
        }
        
        // 轮询结果
        return try await pollReplicateResult(predictionId: predictionId)
    }
    
    /// 轮询 Replicate 结果
    private func pollReplicateResult(predictionId: String) async throws -> Data {
        let maxAttempts = 30
        let pollInterval: TimeInterval = 2.0
        
        for _ in 0..<maxAttempts {
            let url = URL(string: "\(AIProviders.replicate)/predictions/\(predictionId)")!
            var request = URLRequest(url: url)
            request.setValue("Token \(getAPIKey(for: .replicate))", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await session.data(for: request)
            let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let status = jsonResponse?["status"] as? String else {
                throw AIGenerationError.invalidResponse
            }
            
            switch status {
            case "succeeded":
                guard let output = jsonResponse?["output"] as? [String],
                      let imageURL = output.first,
                      let url = URL(string: imageURL) else {
                    throw AIGenerationError.invalidResponse
                }
                
                let (imageData, _) = try await session.data(from: url)
                return imageData
                
            case "failed", "canceled":
                let error = jsonResponse?["error"] as? String ?? "Unknown error"
                throw AIGenerationError.generationFailed(error)
                
            default:
                // 继续轮询
                try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
            }
        }
        
        throw AIGenerationError.timeout
    }
    
    /// 后处理图像
    // 将图像后处理放到主线程，避免 NSImage 跨 actor 的 Sendable 错误
    @MainActor
    private func postProcessImage(_ imageData: Data, parameters: GenerationParameters) async throws -> Data {
        guard let image = NSImage(data: imageData) else {
            throw AIGenerationError.invalidImageData
        }
        let processedImage = try await ensureSquareAspect(image)
        let finalImage = parameters.removeBackground ? try await removeBackground(processedImage) : processedImage
        guard let finalImageData = finalImage.pngData() else {
            throw AIGenerationError.processingFailed
        }
        return finalImageData
    }
    
    // 在主线程上进行 NSImage 绘制/裁剪
    @MainActor
    private func ensureSquareAspect(_ image: NSImage) async throws -> NSImage {
        let size = image.size
        let dimension = min(size.width, size.height)
        let targetSize = CGSize(width: dimension, height: dimension)
        let rect = CGRect(origin: .zero, size: targetSize)
        let croppedImage = NSImage(size: targetSize)
    
        croppedImage.lockFocus()
        // 简化：将图像缩放绘制为正方形画布（若需严格中心裁剪可后续改进为基于 CGImage 的裁剪）
        image.draw(in: rect)
        croppedImage.unlockFocus()
        return croppedImage
    }
    
    // 在主线程上进行 NSImage 相关处理（目前为占位实现）
    @MainActor
    private func removeBackground(_ image: NSImage) async throws -> NSImage {
        return image
    }
}

// MARK: - 常量

/// AI 服务提供商 URL
struct AIProviders {
    static let openAI = "https://api.openai.com/v1"
    static let stability = "https://api.stability.ai/v1"
    static let midjourney = "https://api.midjourney.com/v1"
    static let replicate = "https://api.replicate.com/v1"
}

// MARK: - 数据模型

/// AI 服务提供商
enum AIProvider: String, CaseIterable {
    case openAI = "openai"
    case stability = "stability"
    case midjourney = "midjourney"
    case replicate = "replicate"
    
    var displayName: String {
        switch self {
        case .openAI: return "OpenAI DALL-E"
        case .stability: return "Stability AI"
        case .midjourney: return "Midjourney"
        case .replicate: return "Replicate"
        }
    }
}



/// 生成参数
struct GenerationParameters {
    let size: Int
    let quality: Quality
    let steps: Int
    let cfgScale: Double
    let colorScheme: String?
    let removeBackground: Bool
    let symbols: [String]?

    enum Quality: String {
        case standard = "standard"
        case hd = "hd"
    }

    init(
        size: Int = 1024,
        quality: Quality = .hd,
        steps: Int = 50,
        cfgScale: Double = 7.5,
        colorScheme: String? = nil,
        removeBackground: Bool = true,
        symbols: [String]? = nil
    ) {
        self.size = size
        self.quality = quality
        self.steps = steps
        self.cfgScale = cfgScale
        self.colorScheme = colorScheme
        self.removeBackground = removeBackground
        self.symbols = symbols
    }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "size": size,
            "quality": quality.rawValue,
            "steps": steps,
            "cfgScale": cfgScale,
            "removeBackground": removeBackground
        ]

        if let colorScheme = colorScheme {
            dict["colorScheme"] = colorScheme
        }

        if let symbols = symbols, !symbols.isEmpty {
            dict["symbols"] = symbols.joined(separator: ",")
        }

        return dict
    }
}

/// AI 生成错误
enum AIGenerationError: LocalizedError {
    case invalidPrompt
    case invalidImageData
    case apiError(String)
    case invalidResponse
    case generationFailed(String)
    case timeout
    case processingFailed
    case providerNotAvailable(String)
    case quotaExceeded
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidPrompt:
            return "无效的提示词"
        case .invalidImageData:
            return "无效的图像数据"
        case .apiError(let message):
            return "API 错误: \(message)"
        case .invalidResponse:
            return "无效的 API 响应"
        case .generationFailed(let reason):
            return "生成失败: \(reason)"
        case .timeout:
            return "生成超时"
        case .processingFailed:
            return "图像处理失败"
        case .providerNotAvailable(let message):
            return "服务不可用: \(message)"
        case .quotaExceeded:
            return "使用配额已用完"
        case .rateLimitExceeded:
            return "请求频率超限"
        }
    }
}

// MARK: - 扩展

extension NSImage {
    func pngData() -> Data? {
        // 在主线程上访问 CGImage 更安全，调用方已通过 @MainActor 保证
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        rep.size = self.size
        return rep.representation(using: .png, properties: [:])
    }
}