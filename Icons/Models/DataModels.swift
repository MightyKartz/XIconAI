//
//  DataModels.swift
//  Icons
//
//  Created by Icons Team
//

import Foundation
import SwiftUI

// MARK: - Prompt Template

/// Prompt模板
struct PromptTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: TemplateCategory
    let content: String
    let description: String
    let tags: [String]
    let parameters: [TemplateParameter]
    let previewImage: String?
    let createdAt: Date
    let updatedAt: Date
    let isBuiltIn: Bool
    let popularity: Int
    var usageCount: Int
    let examples: [String]
    
    init(
        id: UUID = UUID(),
        name: String,
        category: TemplateCategory,
        content: String,
        description: String,
        tags: [String] = [],
        parameters: [TemplateParameter] = [],
        previewImage: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isBuiltIn: Bool = false,
        popularity: Int = 0,
        usageCount: Int = 0,
        examples: [String] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.content = content
        self.description = description
        self.tags = tags
        self.parameters = parameters
        self.previewImage = previewImage
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isBuiltIn = isBuiltIn
        self.popularity = popularity
        self.usageCount = usageCount
        self.examples = examples
    }
}

/// 模板分类
enum TemplateCategory: String, CaseIterable, Codable {
    case all = "all"
    case business = "business"
    case creative = "creative"
    case technology = "technology"
    case education = "education"
    case entertainment = "entertainment"
    case lifestyle = "lifestyle"
    case abstract = "abstract"
    case minimalist = "minimalist"
    case vintage = "vintage"
    case modern = "modern"
    
    var displayName: String {
        switch self {
        case .all:
            return "全部"
        case .business:
            return "商务"
        case .creative:
            return "创意"
        case .technology:
            return "科技"
        case .education:
            return "教育"
        case .entertainment:
            return "娱乐"
        case .lifestyle:
            return "生活"
        case .abstract:
            return "抽象"
        case .minimalist:
            return "极简"
        case .vintage:
            return "复古"
        case .modern:
            return "现代"
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "square.grid.2x2"
        case .business:
            return "briefcase"
        case .creative:
            return "paintbrush"
        case .technology:
            return "cpu"
        case .education:
            return "graduationcap"
        case .entertainment:
            return "gamecontroller"
        case .lifestyle:
            return "heart"
        case .abstract:
            return "circle.hexagongrid"
        case .minimalist:
            return "circle"
        case .vintage:
            return "camera.vintage"
        case .modern:
            return "rectangle.3.group"
        }
    }
    
    var color: Color {
        switch self {
        case .all:
            return .primary
        case .business:
            return .blue
        case .creative:
            return .purple
        case .technology:
            return .green
        case .education:
            return .orange
        case .entertainment:
            return .pink
        case .lifestyle:
            return .red
        case .abstract:
            return .indigo
        case .minimalist:
            return .gray
        case .vintage:
            return .brown
        case .modern:
            return .cyan
        }
    }
}

/// 模板参数
struct TemplateParameter: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let displayName: String
    let type: ParameterType
    let defaultValue: String
    let placeholder: String
    let isRequired: Bool
    let options: [String]?
    let minLength: Int?
    let maxLength: Int?
    
    init(
        id: UUID = UUID(),
        name: String,
        displayName: String,
        type: ParameterType,
        defaultValue: String = "",
        placeholder: String = "",
        isRequired: Bool = false,
        options: [String]? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.type = type
        self.defaultValue = defaultValue
        self.placeholder = placeholder
        self.isRequired = isRequired
        self.options = options
        self.minLength = minLength
        self.maxLength = maxLength
    }
}

/// 参数类型
enum ParameterType: String, Codable {
    case text = "text"
    case color = "color"
    case style = "style"
    case mood = "mood"
    case size = "size"
    case select = "select"
    case multiSelect = "multiSelect"
    case number = "number"
    case boolean = "boolean"
    
    var displayName: String {
        switch self {
        case .text:
            return "文本"
        case .color:
            return "颜色"
        case .style:
            return "风格"
        case .mood:
            return "情绪"
        case .size:
            return "尺寸"
        case .select:
            return "选择"
        case .multiSelect:
            return "多选"
        case .number:
            return "数字"
        case .boolean:
            return "布尔值"
        }
    }
}

// MARK: - Generated Icon

/// 生成的图标
struct GeneratedIcon: Identifiable, Codable {
    let id: UUID
    let prompt: String
    let templateId: UUID?
    let imageURL: String
    let localPath: String?
    let thumbnailPath: String?
    let size: CGSize
    let format: String
    let createdAt: Date
    let model: String
    let parameters: [String: String]
    let isFavorite: Bool
    let tags: [String]
    
    init(
        id: UUID = UUID(),
        prompt: String,
        templateId: UUID? = nil,
        imageURL: String,
        localPath: String? = nil,
        thumbnailPath: String? = nil,
        size: CGSize,
        format: String,
        createdAt: Date = Date(),
        model: String,
        parameters: [String: String] = [:],
        isFavorite: Bool = false,
        tags: [String] = []
    ) {
        self.id = id
        self.prompt = prompt
        self.templateId = templateId
        self.imageURL = imageURL
        self.localPath = localPath
        self.thumbnailPath = thumbnailPath
        self.size = size
        self.format = format
        self.createdAt = createdAt
        self.model = model
        self.parameters = parameters
        self.isFavorite = isFavorite
        self.tags = tags
    }
}

// MARK: - SF Symbol

/// SF Symbol信息
struct SFSymbol: Identifiable, Codable, Hashable, Equatable {
    let id: String
    let name: String
    let category: SFSymbolCategory
    let keywords: [String]
    let availability: String
    let variants: [String]
    
    init(
        id: String,
        name: String,
        category: SFSymbolCategory,
        keywords: [String] = [],
        availability: String = "iOS 13.0+",
        variants: [String] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.keywords = keywords
        self.availability = availability
        self.variants = variants
    }
    
    static func == (lhs: SFSymbol, rhs: SFSymbol) -> Bool {
        return lhs.id == rhs.id
    }
}



// MARK: - API Models

/// API请求模型
struct ImageGenerationRequest: Codable {
    let prompt: String
    let model: String
    let size: String
    let quality: String
    let n: Int
    let responseFormat: String
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case model
        case size
        case quality
        case n
        case responseFormat = "response_format"
    }
}

/// API响应模型
struct ImageGenerationResponse: Codable {
    let created: Int
    let data: [ImageData]
}

struct ImageData: Codable {
    let url: String?
    let b64Json: String?
    let revisedPrompt: String?
    
    enum CodingKeys: String, CodingKey {
        case url
        case b64Json = "b64_json"
        case revisedPrompt = "revised_prompt"
    }
}

// MARK: - Error Models

/// API错误响应
struct APIErrorResponse: Codable, Error {
    let error: ErrorDetail
}

struct ErrorDetail: Codable {
    let message: String
    let type: String?
    let param: String?
    let code: String?
}