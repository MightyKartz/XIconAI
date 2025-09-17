//
//  TemplateService.swift
//  Icons
//
//  Created by Icons Team
//

import Foundation
import Combine

/// 模板管理服务
@MainActor
class TemplateService: ObservableObject {
    static let shared = TemplateService()
    
    // MARK: - Published Properties
    
    @Published var templates: [PromptTemplate] = []
    @Published var categories: [TemplateCategory] = TemplateCategory.allCases
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let templatesKey = "SavedTemplates"
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        loadTemplates()
        setupBuiltInTemplates()
    }
    
    // MARK: - Public Methods
    
    /// 获取所有模板
    func getAllTemplates() -> [PromptTemplate] {
        return templates
    }
    
    /// 根据分类获取模板
    func getTemplates(for category: TemplateCategory) -> [PromptTemplate] {
        return templates.filter { $0.category == category }
    }
    
    /// 搜索模板
    func searchTemplates(query: String) -> [PromptTemplate] {
        guard !query.isEmpty else { return templates }
        
        let lowercaseQuery = query.lowercased()
        return templates.filter { template in
            template.name.lowercased().contains(lowercaseQuery) ||
            template.description.lowercased().contains(lowercaseQuery) ||
            template.tags.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }
    
    /// 添加新模板
    func addTemplate(_ template: PromptTemplate) {
        templates.append(template)
        saveTemplates()
    }
    
    /// 更新模板
    func updateTemplate(_ template: PromptTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            var updatedTemplate = template
            updatedTemplate = PromptTemplate(
                id: template.id,
                name: template.name,
                category: template.category,
                content: template.content,
                description: template.description,
                tags: template.tags,
                parameters: template.parameters,
                previewImage: template.previewImage,
                createdAt: template.createdAt,
                updatedAt: Date(),
                isBuiltIn: template.isBuiltIn,
                popularity: template.popularity
            )
            templates[index] = updatedTemplate
            saveTemplates()
        }
    }
    
    /// 删除模板
    func deleteTemplate(_ template: PromptTemplate) {
        guard !template.isBuiltIn else { return } // 不能删除内置模板
        
        templates.removeAll { $0.id == template.id }
        saveTemplates()
    }
    
    /// 增加模板使用次数
    func incrementTemplateUsage(_ template: PromptTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            let updatedTemplate = PromptTemplate(
                id: template.id,
                name: template.name,
                category: template.category,
                content: template.content,
                description: template.description,
                tags: template.tags,
                parameters: template.parameters,
                previewImage: template.previewImage,
                createdAt: template.createdAt,
                updatedAt: template.updatedAt,
                isBuiltIn: template.isBuiltIn,
                popularity: template.popularity + 1
            )
            templates[index] = updatedTemplate
            saveTemplates()
        }
    }
    
    /// 获取热门模板
    func getPopularTemplates(limit: Int = 10) -> [PromptTemplate] {
        return templates
            .sorted { $0.popularity > $1.popularity }
            .prefix(limit)
            .map { $0 }
    }
    
    /// 获取最近使用的模板
    func getRecentTemplates(limit: Int = 5) -> [PromptTemplate] {
        return templates
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(limit)
            .map { $0 }
    }
    
    /// 导出模板
    func exportTemplate(_ template: PromptTemplate) throws -> Data {
        return try JSONEncoder().encode(template)
    }
    
    /// 导入模板
    func importTemplate(from data: Data) throws {
        let template = try JSONDecoder().decode(PromptTemplate.self, from: data)
        
        // 检查是否已存在相同名称的模板
        if templates.contains(where: { $0.name == template.name }) {
            throw TemplateError.duplicateName
        }
        
        // 创建新的ID以避免冲突
        let newTemplate = PromptTemplate(
            name: template.name,
            category: template.category,
            content: template.content,
            description: template.description,
            tags: template.tags,
            parameters: template.parameters,
            previewImage: template.previewImage,
            isBuiltIn: false
        )
        
        addTemplate(newTemplate)
    }
    
    /// 重置为默认模板
    func resetToDefaults() {
        templates.removeAll { !$0.isBuiltIn }
        setupBuiltInTemplates()
        saveTemplates()
    }
    
    // MARK: - Private Methods
    
    private func loadTemplates() {
        if let data = userDefaults.data(forKey: templatesKey),
           let savedTemplates = try? JSONDecoder().decode([PromptTemplate].self, from: data) {
            self.templates = savedTemplates
        }
    }
    
    /// 加载所有模板
    func loadTemplates() async throws -> [PromptTemplate] {
        // 合并内置模板和用户模板
        let builtInTemplates = createBuiltInTemplates()
        let userTemplates = templates.filter { !$0.isBuiltIn }
        let allTemplates = builtInTemplates + userTemplates
        
        return allTemplates.sorted { template1, template2 in
            // 内置模板优先，然后按名称排序
            if template1.isBuiltIn && !template2.isBuiltIn {
                return true
            } else if !template1.isBuiltIn && template2.isBuiltIn {
                return false
            } else {
                return template1.name < template2.name
            }
        }
    }
    
    private func saveTemplates() {
        if let data = try? JSONEncoder().encode(templates) {
            userDefaults.set(data, forKey: templatesKey)
        }
    }
    
    private func setupBuiltInTemplates() {
        // 如果已经有内置模板，则不重复添加
        guard !templates.contains(where: { $0.isBuiltIn }) else { return }
        
        let builtInTemplates = createBuiltInTemplates()
        templates.append(contentsOf: builtInTemplates)
        saveTemplates()
    }
    
    /// 初始化默认模板
    func setupDefaultTemplates() async throws {
        // 内置模板不需要保存到文件，它们通过 createBuiltInTemplates 方法提供
        // 这里可以执行其他初始化逻辑，比如检查模板版本更新等
        print("Template service initialized with \(createBuiltInTemplates().count) built-in templates")
    }
    
    private func createBuiltInTemplates() -> [PromptTemplate] {
        return DefaultTemplates.getAllTemplates()
    }
}

// MARK: - Supporting Types

/// 模板错误
enum TemplateError: LocalizedError {
    case duplicateName
    case invalidFormat
    case missingRequiredFields
    
    var errorDescription: String? {
        switch self {
        case .duplicateName:
            return "模板名称已存在"
        case .invalidFormat:
            return "模板格式无效"
        case .missingRequiredFields:
            return "缺少必需字段"
        }
    }
}