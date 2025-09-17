//
//  DefaultTemplates.swift
//  Icons
//
//  Created by Icons App on 2024/01/15.
//

import Foundation

/// 默认模板库
struct DefaultTemplates {
    
    /// 获取所有默认模板
    static func getAllTemplates() -> [PromptTemplate] {
        return [
            // 基础图标模板
            minimalistIcon,
            modernFlat,
            skeuomorphic,
            
            // 风格化模板
            neonGlow,
            watercolor,
            handDrawn,
            geometric,
            vintage,
            
            // 主题模板
            techIcon,
            natureIcon,
            businessIcon,
            gameIcon,
            
            // 特殊效果模板
            glassEffect,
            metallic,
            gradient3D,
            paperCut,
            
            // 品牌风格模板
            appleStyle,
            googleMaterial,
            microsoftFluent
        ]
    }
    
    // MARK: - 基础图标模板
    
    /// 极简主义图标
    static let minimalistIcon = PromptTemplate(
        id: UUID(),
        name: "极简主义图标",
        category: .minimalist,
        content: "Create a minimalist icon of {subject}, simple geometric shapes, clean lines, monochromatic color scheme, white background, vector style, modern design, {size} resolution",
        description: "简洁、现代的极简风格图标，注重基本形状和清晰的轮廓",
        tags: ["极简", "现代", "几何"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "house", placeholder: "输入图标主题，如：house, car, phone", isRequired: true),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 现代扁平化
    static let modernFlat = PromptTemplate(
        id: UUID(),
        name: "现代扁平化",
        category: .modern,
        content: "Modern flat design icon of {subject}, vibrant colors, no shadows, simple shapes, {color_scheme} color palette, clean background, vector illustration, {size} resolution",
        description: "扁平化设计风格，使用鲜艳色彩和简单形状",
        tags: ["扁平化", "现代", "鲜艳"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "geometric shape", placeholder: "输入几何主题", isRequired: true),
            TemplateParameter(name: "color_scheme", displayName: "配色方案", type: .select, defaultValue: "bright", isRequired: true, options: ["bright", "pastel", "monochrome", "gradient"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 拟物化设计
    static let skeuomorphic = PromptTemplate(
        id: UUID(),
        name: "拟物化设计",
        category: .modern,
        content: "Skeuomorphic icon of {subject}, realistic textures, detailed shadows, highlights, 3D appearance, {material} material, glossy finish, {size} resolution, professional quality",
        description: "真实质感的拟物化图标，具有阴影、高光和纹理",
        tags: ["拟物化", "3D", "真实"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "folder", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "material", displayName: "材质", type: .select, defaultValue: "plastic", isRequired: true, options: ["plastic", "metal", "glass", "wood", "leather"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    // MARK: - 风格化模板
    
    /// 霓虹发光
    static let neonGlow = PromptTemplate(
        id: UUID(),
        name: "霓虹发光",
        category: .creative,
        content: "Neon glowing icon of {subject}, bright {color} neon lights, dark background, electric glow effect, cyberpunk style, high contrast, {size} resolution",
        description: "霓虹灯效果的发光图标，适合夜间主题",
        tags: ["霓虹", "发光", "赛博朋克"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "lightning", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "color", displayName: "霓虹颜色", type: .select, defaultValue: "blue", isRequired: true, options: ["blue", "pink", "green", "purple", "orange", "multicolor"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 水彩风格
    static let watercolor = PromptTemplate(
        id: UUID(),
        name: "水彩风格",
        category: .creative,
        content: "Watercolor style icon of {subject}, soft brush strokes, {color_palette} colors, artistic texture, paper background, hand-painted look, {size} resolution",
        description: "柔和的水彩画风格图标，具有艺术感",
        tags: ["水彩", "艺术", "手绘"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "flower", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "color_palette", displayName: "色彩调性", type: .select, defaultValue: "warm", isRequired: true, options: ["warm", "cool", "earth", "pastel", "vibrant"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 手绘风格
    static let handDrawn = PromptTemplate(
        id: UUID(),
        name: "手绘风格",
        category: .creative,
        content: "Hand-drawn sketch icon of {subject}, pencil lines, {style} style, organic shapes, imperfect lines, artistic charm, white background, {size} resolution",
        description: "手绘素描风格的图标，具有人文气息",
        tags: ["手绘", "素描", "艺术"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "tree", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "style", displayName: "绘画风格", type: .select, defaultValue: "sketch", isRequired: true, options: ["sketch", "doodle", "crosshatch", "outline"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 几何抽象
    static let geometric = PromptTemplate(
        id: UUID(),
        name: "几何抽象",
        category: .creative,
        content: "Geometric abstract icon representing {subject}, {shape_style} shapes, {color_count} colors, mathematical precision, modern art style, {size} resolution",
        description: "抽象几何形状组成的现代图标",
        tags: ["几何", "抽象", "现代"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "music", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "shape_style", displayName: "形状风格", type: .select, defaultValue: "angular", isRequired: true, options: ["angular", "curved", "mixed", "polygonal"]),
            TemplateParameter(name: "color_count", displayName: "颜色数量", type: .select, defaultValue: "3-4", isRequired: true, options: ["2", "3-4", "5-6", "multicolor"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 复古风格
    static let vintage = PromptTemplate(
        id: UUID(),
        name: "复古风格",
        category: .vintage,
        content: "Vintage style icon of {subject}, {era} era design, retro colors, aged texture, classic typography, nostalgic feel, {size} resolution",
        description: "怀旧复古风格的图标设计",
        tags: ["复古", "怀旧", "经典"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "radio", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "era", displayName: "年代风格", type: .select, defaultValue: "1950s", isRequired: true, options: ["1920s", "1950s", "1970s", "1980s"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    // MARK: - 主题模板
    
    /// 科技图标
    static let techIcon = PromptTemplate(
        id: UUID(),
        name: "科技图标",
        category: .creative,
        content: "High-tech icon of {subject}, futuristic design, {tech_style} aesthetic, digital elements, circuit patterns, metallic finish, {size} resolution",
        description: "现代科技感的图标设计",
        tags: ["科技", "未来", "数字"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "gamepad", placeholder: "输入游戏相关主题", isRequired: true),
            TemplateParameter(name: "tech_style", displayName: "科技风格", type: .select, defaultValue: "cyberpunk", isRequired: true, options: ["cyberpunk", "minimalist", "industrial", "holographic"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 自然图标
    static let natureIcon = PromptTemplate(
        id: UUID(),
        name: "自然图标",
        category: .lifestyle,
        content: "Nature-inspired icon of {subject}, organic shapes, {nature_style} style, earth tones, natural textures, eco-friendly design, {size} resolution",
        description: "自然主题的有机图标设计",
        tags: ["自然", "有机", "环保"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "briefcase", placeholder: "输入商务相关主题", isRequired: true),
            TemplateParameter(name: "nature_style", displayName: "自然风格", type: .select, defaultValue: "botanical", isRequired: true, options: ["botanical", "landscape", "wildlife", "abstract"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 商务图标
    static let businessIcon = PromptTemplate(
        id: UUID(),
        name: "商务图标",
        category: .business,
        content: "Professional business icon of {subject}, corporate style, {business_tone} tone, clean design, trustworthy appearance, {size} resolution",
        description: "专业的商务风格图标设计",
        tags: ["商务", "专业", "企业"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "briefcase", placeholder: "输入商务相关主题", isRequired: true),
            TemplateParameter(name: "business_tone", displayName: "商务调性", type: .select, defaultValue: "conservative", isRequired: true, options: ["conservative", "modern", "creative", "luxury"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 游戏图标
    static let gameIcon = PromptTemplate(
        id: UUID(),
        name: "游戏图标",
        category: .entertainment,
        content: "Game-style icon of {subject}, {game_genre} game aesthetic, vibrant colors, dynamic design, playful elements, {size} resolution",
        description: "游戏风格的动感图标设计",
        tags: ["游戏", "动感", "娱乐"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "sword", placeholder: "输入游戏相关主题", isRequired: true),
            TemplateParameter(name: "game_genre", displayName: "游戏类型", type: .select, defaultValue: "fantasy", isRequired: true, options: ["fantasy", "sci-fi", "cartoon", "pixel", "realistic"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    // MARK: - 特殊效果模板
    
    /// 玻璃效果
    static let glassEffect = PromptTemplate(
        id: UUID(),
        name: "玻璃效果",
        category: .creative,
        content: "Glass effect icon of {subject}, transparent material, {glass_style} glass, reflections, refractions, modern design, {size} resolution",
        description: "透明玻璃质感的现代图标",
        tags: ["玻璃", "透明", "现代"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "vintage car", placeholder: "输入复古主题", isRequired: true),
            TemplateParameter(name: "glass_style", displayName: "玻璃风格", type: .select, defaultValue: "frosted", isRequired: true, options: ["clear", "frosted", "tinted", "crystalline"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 金属质感
    static let metallic = PromptTemplate(
        id: UUID(),
        name: "金属质感",
        category: .creative,
        content: "Metallic icon of {subject}, {metal_type} metal finish, industrial design, reflective surface, detailed textures, {size} resolution",
        description: "金属材质的工业风图标",
        tags: ["金属", "工业", "质感"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "gear", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "metal_type", displayName: "金属类型", type: .select, defaultValue: "steel", isRequired: true, options: ["steel", "chrome", "gold", "copper", "titanium"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 3D渐变
    static let gradient3D = PromptTemplate(
        id: UUID(),
        name: "3D渐变",
        category: .creative,
        content: "3D gradient icon of {subject}, {gradient_style} gradient, depth effect, modern design, smooth transitions, {size} resolution",
        description: "立体渐变效果的现代图标",
        tags: ["3D", "渐变", "立体"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "sphere", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "gradient_style", displayName: "渐变风格", type: .select, defaultValue: "radial", isRequired: true, options: ["linear", "radial", "conical", "mesh"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// 纸艺风格
    static let paperCut = PromptTemplate(
        id: UUID(),
        name: "纸艺风格",
        category: .creative,
        content: "Paper cut art icon of {subject}, layered paper design, {paper_style} style, shadow effects, craft aesthetic, {size} resolution",
        description: "纸张剪切艺术风格的图标",
        tags: ["纸艺", "手工", "层次"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "butterfly", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "paper_style", displayName: "纸艺风格", type: .select, defaultValue: "layered", isRequired: true, options: ["layered", "origami", "kirigami", "popup"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    // MARK: - 品牌风格模板
    
    /// Apple风格
    static let appleStyle = PromptTemplate(
        id: UUID(),
        name: "Apple风格",
        category: .business,
        content: "Apple-style icon of {subject}, iOS design language, rounded corners, subtle shadows, clean aesthetics, {ios_version} style, {size} resolution",
        description: "Apple设计语言的简洁图标",
        tags: ["Apple", "iOS", "简洁"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "settings", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "ios_version", displayName: "iOS版本风格", type: .select, defaultValue: "iOS17", isRequired: true, options: ["iOS14", "iOS15", "iOS16", "iOS17"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// Google Material风格
    static let googleMaterial = PromptTemplate(
        id: UUID(),
        name: "Material Design",
        category: .business,
        content: "Material Design icon of {subject}, Google design system, {material_version} guidelines, bold colors, geometric shapes, {size} resolution",
        description: "Google Material Design风格图标",
        tags: ["Google", "Material", "几何"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "crystal", placeholder: "输入玻璃效果主题", isRequired: true),
            TemplateParameter(name: "material_version", displayName: "Material版本", type: .select, defaultValue: "Material3", isRequired: true, options: ["Material2", "Material3", "MaterialYou"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
    
    /// Microsoft Fluent风格
    static let microsoftFluent = PromptTemplate(
        id: UUID(),
        name: "Fluent Design",
        category: .business,
        content: "Fluent Design icon of {subject}, Microsoft design system, {fluent_style} style, depth and motion, acrylic materials, {size} resolution",
        description: "Microsoft Fluent Design风格图标",
        tags: ["Microsoft", "Fluent", "深度"],
        parameters: [
            TemplateParameter(name: "subject", displayName: "主题", type: .text, defaultValue: "document", placeholder: "输入图标主题", isRequired: true),
            TemplateParameter(name: "fluent_style", displayName: "Fluent风格", type: .select, defaultValue: "modern", isRequired: true, options: ["classic", "modern", "colorful", "monochrome"]),
            TemplateParameter(name: "size", displayName: "尺寸", type: .select, defaultValue: "1024x1024", isRequired: true, options: ["512x512", "1024x1024", "2048x2048"])
        ],
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true
    )
}

// MARK: - 模板参数扩展

extension TemplateParameter {
    /// 创建文本参数的便捷方法
    static func text(name: String, displayName: String, defaultValue: String = "", isRequired: Bool = true, placeholder: String = "") -> TemplateParameter {
        return TemplateParameter(
            name: name,
            displayName: displayName,
            type: .text,
            defaultValue: defaultValue,
            placeholder: placeholder,
            isRequired: isRequired
        )
    }
    
    /// 创建选择参数的便捷方法
    static func selection(name: String, displayName: String, defaultValue: String, options: [String], isRequired: Bool = true) -> TemplateParameter {
        return TemplateParameter(
            name: name,
            displayName: displayName,
            type: .select,
            defaultValue: defaultValue,
            isRequired: isRequired,
            options: options
        )
    }
    
    /// 创建数字参数的便捷方法
    static func number(name: String, displayName: String, defaultValue: String, isRequired: Bool = true, placeholder: String = "") -> TemplateParameter {
        return TemplateParameter(
            name: name,
            displayName: displayName,
            type: .number,
            defaultValue: defaultValue,
            placeholder: placeholder,
            isRequired: isRequired
        )
    }
}