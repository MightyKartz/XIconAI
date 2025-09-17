//
//  AppState.swift
//  Icons
//
//  Created by Icons App on 2024/01/01.
//

import SwiftUI
import Combine

/// 底部标签枚举
enum BottomTab: String, CaseIterable, Identifiable {
    case templates = "templates"
    case sfSymbols = "sfSymbols"
    case parameters = "parameters"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .templates:
            return "模板"
        case .sfSymbols:
            return "SF 符号"
        case .parameters:
            return "参数设置"
        }
    }

    var icon: String {
        switch self {
        case .templates:
            return "doc.text"
        case .sfSymbols:
            return "square.grid.3x2"
        case .parameters:
            return "slider.horizontal.3"
        }
    }
}

// MARK: - AI 服务枚举
enum AIService: String, CaseIterable, Identifiable {
    case openai = "openai"
    case anthropic = "anthropic"
    case stability = "stability"
    case midjourney = "midjourney"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .openai: return "OpenAI"
        case .anthropic: return "Anthropic"
        case .stability: return "Stability AI"
        case .midjourney: return "Midjourney"
        }
    }
    
    var icon: String {
        switch self {
        case .openai: return "brain.head.profile"
        case .anthropic: return "cpu"
        case .stability: return "wand.and.stars"
        case .midjourney: return "paintbrush.pointed"
        }
    }
    
    var availableModels: [String] {
        switch self {
        case .openai:
            return ["dall-e-3", "dall-e-2"]
        case .anthropic:
            return ["claude-3-opus", "claude-3-sonnet"]
        case .stability:
            return ["stable-diffusion-xl", "stable-diffusion-2.1"]
        case .midjourney:
            return ["midjourney-v6", "midjourney-v5.2"]
        }
    }
}

// MARK: - 图像质量枚举
enum ImageQuality: String, CaseIterable, Hashable, Identifiable, Equatable {
    case standard = "standard"
    case high = "high"
    case ultra = "ultra"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .standard: return "标准"
        case .high: return "高质量"
        case .ultra: return "超高清"
        }
    }
    
    var description: String {
        switch self {
        case .standard: return "快速生成，适合预览"
        case .high: return "平衡质量与速度"
        case .ultra: return "最高质量，生成较慢"
        }
    }
}

// MARK: - 导出格式枚举
enum ExportFormat: String, CaseIterable, Identifiable {
    case png = "png"
    case svg = "svg"
    case pdf = "pdf"
    case icns = "icns"
    case ico = "ico"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .png: return "PNG"
        case .svg: return "SVG"
        case .pdf: return "PDF"
        case .icns: return "ICNS"
        case .ico: return "ICO"
        }
    }
    
    var description: String {
        switch self {
        case .png: return "位图格式，支持透明"
        case .svg: return "矢量格式，无限缩放"
        case .pdf: return "矢量格式，打印友好"
        case .icns: return "macOS 图标格式"
        case .ico: return "Windows 图标格式"
        }
    }
    
    var icon: String {
        switch self {
        case .png: return "photo"
        case .svg: return "vector"
        case .pdf: return "doc.richtext"
        case .icns: return "app.badge"
        case .ico: return "app.badge.fill"
        }
    }
}

// MARK: - 导出尺寸枚举
enum ExportSize: String, CaseIterable, Identifiable {
    case size512 = "512"
    case size1024 = "1024"
    case size2048 = "2048"
    case size4096 = "4096"
    case custom = "custom"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .size512: return "512×512"
        case .size1024: return "1024×1024"
        case .size2048: return "2048×2048"
        case .size4096: return "4096×4096"
        case .custom: return "自定义"
        }
    }
    
    var description: String {
        switch self {
        case .size512: return "小尺寸，适合网页"
        case .size1024: return "标准尺寸，通用"
        case .size2048: return "高清尺寸，打印"
        case .size4096: return "超高清，专业用途"
        case .custom: return "自定义尺寸"
        }
    }
    
    var pixelSize: (width: Int, height: Int)? {
        switch self {
        case .size512: return (512, 512)
        case .size1024: return (1024, 1024)
        case .size2048: return (2048, 2048)
        case .size4096: return (4096, 4096)
        case .custom: return nil
        }
    }
}

// MARK: - 应用状态管理
@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    // MARK: - 生成相关状态
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var currentPrompt = ""
    @Published var userPrompt = ""  // 用户输入的提示词
    @Published var selectedSFSymbols: [String] = []  // 选中的SF符号
    @Published var selectedStyle: IconStyle = .minimalist
    @Published var generatedIcons: [GeneratedIcon] = []
    @Published var currentSessionIcons: [GeneratedIcon] = []
    @Published var selectedTemplate: PromptTemplate?
    @Published var templates: [PromptTemplate] = []
    @Published var templateParameters: [String: String] = [:]  // 模板参数值

    // MARK: - AI 服务配置
    @Published var selectedAIService: AIService = .openai
    @Published var selectedModel = "dall-e-3"
    @Published var imageQuality: ImageQuality = .high
    @Published var generationCount = 1
    @Published var autoOptimizePrompts = true
    @Published var enableBatchGeneration = false
    @Published var batchSize = 2
    @Published var removeBackground = true
    
    // MARK: - API 设置
    @Published var apiKey = ""
    @Published var apiEndpoint = "https://api.openai.com/v1"
    @Published var requestTimeout: TimeInterval = 60
    
    // MARK: - 导出设置
    @Published var defaultExportFormat: ExportFormat = .png
    @Published var defaultExportSize: ExportSize = .size1024
    @Published var customExportWidth = 1024
    @Published var customExportHeight = 1024
    @Published var exportFolderPath = "~/Downloads/Icons"
    @Published var autoCreateSubfolders = true
    @Published var includeMetadata = false
    @Published var generateThumbnails = true
    @Published var preserveOriginalNames = false
    @Published var filenameTemplate = "icon_{name}_{size}"
    @Published var pngCompressionLevel: Double = 0.8
    @Published var jpegQuality: Double = 0.9
    
    // MARK: - 导航状态
    @Published var selectedTab: NavigationTab = .generate
    @Published var showingSidebar = true
    @Published var selectedBottomTab: BottomTab = .templates
    
    // MARK: - 错误处理
    @Published var errorMessage: String?
    @Published var showingError = false
    
    // Combine 订阅保留
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSettings()
        
        // 初始化模板：从 TemplateService 同步一次，并持续订阅其变化
        templates = TemplateService.shared.getAllTemplates()
        TemplateService.shared.$templates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTemplates in
                self?.templates = newTemplates
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 设置管理
    private func loadSettings() {
        // 从 UserDefaults 加载设置
        // 停止持久化 selectedAIService/selectedModel
        // if let serviceRaw = UserDefaults.standard.object(forKey: "selectedAIService") as? String,
        //    let service = AIService(rawValue: serviceRaw) {
        //     selectedAIService = service
        // }

        // selectedModel = UserDefaults.standard.string(forKey: "selectedModel") ?? selectedAIService.availableModels.first ?? ""

        if let qualityRaw = UserDefaults.standard.object(forKey: "imageQuality") as? String,
           let quality = ImageQuality(rawValue: qualityRaw) {
            imageQuality = quality
        }

        generationCount = UserDefaults.standard.object(forKey: "generationCount") as? Int ?? 1
        autoOptimizePrompts = UserDefaults.standard.bool(forKey: "autoOptimizePrompts")

        exportFolderPath = UserDefaults.standard.string(forKey: "exportFolderPath") ?? "~/Downloads/Icons"
        filenameTemplate = UserDefaults.standard.string(forKey: "filenameTemplate") ?? "icon_{name}_{size}"
    }
    
    func saveSettings() {
        // 停止持久化 selectedAIService/selectedModel
        // UserDefaults.standard.set(selectedAIService.rawValue, forKey: "selectedAIService")
        // UserDefaults.standard.set(selectedModel, forKey: "selectedModel")
        UserDefaults.standard.set(imageQuality.rawValue, forKey: "imageQuality")
        UserDefaults.standard.set(generationCount, forKey: "generationCount")
        UserDefaults.standard.set(autoOptimizePrompts, forKey: "autoOptimizePrompts")
        UserDefaults.standard.set(exportFolderPath, forKey: "exportFolderPath")
        UserDefaults.standard.set(filenameTemplate, forKey: "filenameTemplate")
    }
    
    // MARK: - 导出文件夹管理
    func setExportFolder(_ path: String) {
        exportFolderPath = path
        saveSettings()
    }
    
    // MARK: - 图标生成
    func startGeneration(prompt: String) {
        guard !isGenerating else { return }
        
        currentPrompt = prompt
        isGenerating = true
        generationProgress = 0.0
        
        // 模拟生成过程
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            DispatchQueue.main.async {
                self.generationProgress += 0.02
                
                if self.generationProgress >= 1.0 {
                    timer.invalidate()
                    self.completeGeneration()
                }
            }
        }
    }
    
    private func completeGeneration() {
        isGenerating = false
        generationProgress = 0.0
        
        // 添加模拟生成的图标
        let newIcons = (1...generationCount).map { index in
            GeneratedIcon(
                id: UUID(),
                prompt: currentPrompt,
                imageURL: "https://example.com/icon_\(index).png",
                size: CGSize(width: 1024, height: 1024),
                format: "png",
                createdAt: Date(),
                model: selectedModel
            )
        }
        
        generatedIcons.append(contentsOf: newIcons)
    }
    
    // MARK: - 模板管理
    func saveTemplate(_ template: PromptTemplate) {
        if TemplateService.shared.getAllTemplates().contains(where: { $0.id == template.id }) {
            TemplateService.shared.updateTemplate(template)
        } else {
            TemplateService.shared.addTemplate(template)
        }
        // 同步最新模板
        templates = TemplateService.shared.getAllTemplates()
    }
    
    func deleteTemplate(_ template: PromptTemplate) {
        TemplateService.shared.deleteTemplate(template)
        // 同步最新模板
        templates = TemplateService.shared.getAllTemplates()
    }
    
    @MainActor
    func incrementTemplateUsage(_ templateId: UUID) {
        if let template = templates.first(where: { $0.id == templateId }) {
            TemplateService.shared.incrementTemplateUsage(template)
            // 重新加载模板以反映更新
            templates = TemplateService.shared.getAllTemplates()
        }
    }
    
    // MARK: - 错误处理
    func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    func clearError() {
        errorMessage = nil
        showingError = false
    }
}