//
//  IconStyle.swift
//  Icons
//
//  Created by Icons App on 2024/01/15.
//

import Foundation

/// 图标风格枚举
enum IconStyle: String, CaseIterable, Codable, Identifiable {
    var id: String { rawValue }
    // MARK: - 基础风格
    case minimalist = "minimalist"
    case flat = "flat"
    case outline = "outline"
    case filled = "filled"
    case gradient = "gradient"
    case shadow = "shadow"
    
    // MARK: - 艺术风格
    case watercolor = "watercolor"
    case sketch = "sketch"
    case cartoon = "cartoon"
    case realistic = "realistic"
    case abstract = "abstract"
    case geometric = "geometric"
    
    // MARK: - 材质风格
    case glass = "glass"
    case metal = "metal"
    case wood = "wood"
    case plastic = "plastic"
    case fabric = "fabric"
    case paper = "paper"
    
    // MARK: - 特效风格
    case neon = "neon"
    case glow = "glow"
    case embossed = "embossed"
    case vintage = "vintage"
    case retro = "retro"
    case futuristic = "futuristic"
    
    // MARK: - 主题风格
    case business = "business"
    case gaming = "gaming"
    case education = "education"
    case medical = "medical"
    case technology = "technology"
    case nature = "nature"
    
    // MARK: - 显示名称
    var displayName: String {
        switch self {
        // 基础风格
        case .minimalist: return "极简主义"
        case .flat: return "扁平化"
        case .outline: return "线条"
        case .filled: return "填充"
        case .gradient: return "渐变"
        case .shadow: return "阴影"
        
        // 艺术风格
        case .watercolor: return "水彩"
        case .sketch: return "手绘"
        case .cartoon: return "卡通"
        case .realistic: return "写实"
        case .abstract: return "抽象"
        case .geometric: return "几何"
        
        // 材质风格
        case .glass: return "玻璃"
        case .metal: return "金属"
        case .wood: return "木质"
        case .plastic: return "塑料"
        case .fabric: return "织物"
        case .paper: return "纸质"
        
        // 特效风格
        case .neon: return "霓虹"
        case .glow: return "发光"
        case .embossed: return "浮雕"
        case .vintage: return "复古"
        case .retro: return "怀旧"
        case .futuristic: return "未来"
        
        // 主题风格
        case .business: return "商务"
        case .gaming: return "游戏"
        case .education: return "教育"
        case .medical: return "医疗"
        case .technology: return "科技"
        case .nature: return "自然"
        }
    }
    
    // MARK: - 描述
    var description: String {
        switch self {
        // 基础风格
        case .minimalist: return "简洁清爽，去除多余元素，突出核心内容"
        case .flat: return "扁平化设计，无阴影和立体效果，色彩鲜明"
        case .outline: return "线条勾勒，简洁的轮廓设计"
        case .filled: return "实心填充，色彩饱满的图标设计"
        case .gradient: return "渐变色彩，丰富的色彩过渡效果"
        case .shadow: return "带有阴影效果，增加立体感"
        
        // 艺术风格
        case .watercolor: return "水彩画风格，柔和的色彩晕染效果"
        case .sketch: return "手绘素描风格，自然的线条和纹理"
        case .cartoon: return "卡通动漫风格，可爱生动的表现形式"
        case .realistic: return "写实风格，接近真实物体的表现"
        case .abstract: return "抽象艺术风格，富有创意的表现形式"
        case .geometric: return "几何图形风格，规整的形状组合"
        
        // 材质风格
        case .glass: return "玻璃材质效果，透明和反射特性"
        case .metal: return "金属材质效果，光泽和质感"
        case .wood: return "木质纹理效果，自然温暖的质感"
        case .plastic: return "塑料材质效果，光滑的表面质感"
        case .fabric: return "织物纹理效果，柔软的材质表现"
        case .paper: return "纸质纹理效果，朴素的材质感"
        
        // 特效风格
        case .neon: return "霓虹灯效果，鲜艳的发光边缘"
        case .glow: return "发光效果，柔和的光晕围绕"
        case .embossed: return "浮雕效果，立体的凹凸质感"
        case .vintage: return "复古风格，怀旧的色调和质感"
        case .retro: return "怀旧风格，经典的设计元素"
        case .futuristic: return "未来科技风格，现代感的设计"
        
        // 主题风格
        case .business: return "商务专业风格，正式严谨的设计"
        case .gaming: return "游戏风格，动感活力的表现"
        case .education: return "教育主题风格，友好易懂的设计"
        case .medical: return "医疗主题风格，清洁专业的表现"
        case .technology: return "科技风格，现代数字化的设计"
        case .nature: return "自然主题风格，有机生态的表现"
        }
    }
    
    // MARK: - 分类
    var category: StyleCategory {
        switch self {
        case .minimalist, .flat, .outline, .filled, .gradient, .shadow:
            return .basic
        case .watercolor, .sketch, .cartoon, .realistic, .abstract, .geometric:
            return .artistic
        case .glass, .metal, .wood, .plastic, .fabric, .paper:
            return .material
        case .neon, .glow, .embossed, .vintage, .retro, .futuristic:
            return .effect
        case .business, .gaming, .education, .medical, .technology, .nature:
            return .theme
        }
    }
    
    // MARK: - 推荐用途
    var recommendedUse: [String] {
        switch self {
        case .minimalist:
            return ["应用图标", "网站图标", "UI界面", "品牌标识"]
        case .flat:
            return ["移动应用", "网页设计", "界面元素", "信息图表"]
        case .outline:
            return ["线性图标", "界面按钮", "导航元素", "说明图标"]
        case .filled:
            return ["应用图标", "按钮设计", "状态指示", "分类标识"]
        case .gradient:
            return ["现代应用", "品牌设计", "装饰元素", "背景图案"]
        case .shadow:
            return ["立体按钮", "卡片设计", "界面元素", "装饰图标"]
        
        case .watercolor:
            return ["艺术应用", "创意设计", "儿童应用", "文艺品牌"]
        case .sketch:
            return ["手工应用", "创意工具", "设计软件", "艺术平台"]
        case .cartoon:
            return ["儿童应用", "游戏图标", "娱乐软件", "社交应用"]
        case .realistic:
            return ["摄影应用", "工具软件", "专业应用", "模拟器"]
        case .abstract:
            return ["艺术应用", "创意软件", "音乐应用", "设计工具"]
        case .geometric:
            return ["数学应用", "设计软件", "建筑应用", "科学工具"]
        
        case .glass:
            return ["现代应用", "系统工具", "透明效果", "高端品牌"]
        case .metal:
            return ["工业应用", "专业工具", "机械软件", "技术品牌"]
        case .wood:
            return ["自然应用", "手工软件", "传统工艺", "温馨品牌"]
        case .plastic:
            return ["玩具应用", "儿童软件", "休闲游戏", "轻松品牌"]
        case .fabric:
            return ["时尚应用", "纺织软件", "手工应用", "温暖品牌"]
        case .paper:
            return ["文档应用", "笔记软件", "阅读应用", "简约品牌"]
        
        case .neon:
            return ["夜店应用", "音乐软件", "娱乐应用", "时尚品牌"]
        case .glow:
            return ["科幻应用", "游戏软件", "特效工具", "未来品牌"]
        case .embossed:
            return ["奢华应用", "传统软件", "工艺应用", "高端品牌"]
        case .vintage:
            return ["复古应用", "怀旧软件", "经典游戏", "传统品牌"]
        case .retro:
            return ["怀旧应用", "经典软件", "复古游戏", "年代品牌"]
        case .futuristic:
            return ["科技应用", "未来软件", "科幻游戏", "创新品牌"]
        
        case .business:
            return ["商务应用", "办公软件", "企业工具", "专业品牌"]
        case .gaming:
            return ["游戏应用", "娱乐软件", "竞技平台", "游戏品牌"]
        case .education:
            return ["教育应用", "学习软件", "培训工具", "教育品牌"]
        case .medical:
            return ["医疗应用", "健康软件", "医疗工具", "医疗品牌"]
        case .technology:
            return ["科技应用", "开发工具", "技术软件", "科技品牌"]
        case .nature:
            return ["环保应用", "户外软件", "自然工具", "生态品牌"]
        }
    }
    
    // MARK: - 颜色建议
    var suggestedColors: [String] {
        switch self {
        case .minimalist:
            return ["黑色", "白色", "灰色", "蓝色"]
        case .flat:
            return ["鲜艳色彩", "对比色", "品牌色", "明亮色"]
        case .outline:
            return ["单色", "深色", "品牌色", "对比色"]
        case .filled:
            return ["饱和色", "品牌色", "对比色", "鲜艳色"]
        case .gradient:
            return ["渐变色", "彩虹色", "冷暖色", "品牌色"]
        case .shadow:
            return ["深色", "中性色", "品牌色", "对比色"]
        
        case .watercolor:
            return ["柔和色", "水彩色", "淡雅色", "自然色"]
        case .sketch:
            return ["铅笔色", "素描色", "单色", "自然色"]
        case .cartoon:
            return ["鲜艳色", "可爱色", "对比色", "活泼色"]
        case .realistic:
            return ["真实色", "自然色", "写实色", "环境色"]
        case .abstract:
            return ["创意色", "艺术色", "对比色", "表现色"]
        case .geometric:
            return ["几何色", "规整色", "对比色", "简洁色"]
        
        case .glass:
            return ["透明色", "反射色", "冷色调", "清澈色"]
        case .metal:
            return ["金属色", "银色", "铜色", "光泽色"]
        case .wood:
            return ["木色", "棕色", "自然色", "温暖色"]
        case .plastic:
            return ["鲜艳色", "光滑色", "人工色", "明亮色"]
        case .fabric:
            return ["织物色", "柔和色", "温暖色", "自然色"]
        case .paper:
            return ["纸色", "米色", "朴素色", "自然色"]
        
        case .neon:
            return ["荧光色", "鲜艳色", "发光色", "对比色"]
        case .glow:
            return ["发光色", "明亮色", "光晕色", "柔和色"]
        case .embossed:
            return ["金色", "银色", "深色", "奢华色"]
        case .vintage:
            return ["复古色", "怀旧色", "褪色", "经典色"]
        case .retro:
            return ["怀旧色", "年代色", "经典色", "复古色"]
        case .futuristic:
            return ["科技色", "冷色调", "金属色", "未来色"]
        
        case .business:
            return ["商务色", "专业色", "深色", "品牌色"]
        case .gaming:
            return ["游戏色", "鲜艳色", "对比色", "动感色"]
        case .education:
            return ["教育色", "友好色", "温和色", "学习色"]
        case .medical:
            return ["医疗色", "清洁色", "专业色", "健康色"]
        case .technology:
            return ["科技色", "数字色", "现代色", "创新色"]
        case .nature:
            return ["自然色", "绿色", "生态色", "有机色"]
        }
    }
}

// MARK: - 风格分类
enum StyleCategory: String, CaseIterable {
    case basic = "basic"
    case artistic = "artistic"
    case material = "material"
    case effect = "effect"
    case theme = "theme"
    
    var displayName: String {
        switch self {
        case .basic: return "基础风格"
        case .artistic: return "艺术风格"
        case .material: return "材质风格"
        case .effect: return "特效风格"
        case .theme: return "主题风格"
        }
    }
    
    var description: String {
        switch self {
        case .basic: return "基础的图标设计风格，适用于大多数场景"
        case .artistic: return "艺术化的图标风格，富有创意和表现力"
        case .material: return "模拟真实材质的图标风格，质感丰富"
        case .effect: return "带有特殊效果的图标风格，视觉冲击力强"
        case .theme: return "特定主题的图标风格，针对性强"
        }
    }
    
    var styles: [IconStyle] {
        return IconStyle.allCases.filter { $0.category == self }
    }
}

// MARK: - 扩展方法
extension IconStyle {
    /// 获取风格的提示词修饰符
    var promptModifier: String {
        switch self {
        case .minimalist:
            return "minimalist, clean, simple, modern"
        case .flat:
            return "flat design, no shadows, bright colors"
        case .outline:
            return "outline style, line art, stroke only"
        case .filled:
            return "filled, solid colors, no outlines"
        case .gradient:
            return "gradient colors, smooth transitions"
        case .shadow:
            return "drop shadow, 3D effect, depth"
        
        case .watercolor:
            return "watercolor style, soft edges, paint bleeding"
        case .sketch:
            return "hand drawn, sketch style, pencil lines"
        case .cartoon:
            return "cartoon style, cute, animated"
        case .realistic:
            return "realistic, photorealistic, detailed"
        case .abstract:
            return "abstract art, creative, artistic"
        case .geometric:
            return "geometric shapes, mathematical, precise"
        
        case .glass:
            return "glass material, transparent, reflective"
        case .metal:
            return "metallic, chrome, shiny surface"
        case .wood:
            return "wood texture, natural grain, organic"
        case .plastic:
            return "plastic material, smooth, artificial"
        case .fabric:
            return "fabric texture, soft, textile"
        case .paper:
            return "paper texture, matte, natural"
        
        case .neon:
            return "neon lights, glowing edges, bright"
        case .glow:
            return "glowing effect, soft light, luminous"
        case .embossed:
            return "embossed, raised surface, tactile"
        case .vintage:
            return "vintage style, aged, retro colors"
        case .retro:
            return "retro design, nostalgic, classic"
        case .futuristic:
            return "futuristic, sci-fi, modern technology"
        
        case .business:
            return "professional, corporate, formal"
        case .gaming:
            return "gaming style, dynamic, energetic"
        case .education:
            return "educational, friendly, approachable"
        case .medical:
            return "medical theme, clean, professional"
        case .technology:
            return "tech style, digital, modern"
        case .nature:
            return "nature theme, organic, eco-friendly"
        }
    }
    
    /// 根据分类获取风格列表
    static func styles(for category: StyleCategory) -> [IconStyle] {
        return allCases.filter { $0.category == category }
    }
    
    /// 获取推荐的相似风格
    var similarStyles: [IconStyle] {
        let sameCategory = IconStyle.styles(for: self.category).filter { $0 != self }
        return Array(sameCategory.prefix(3))
    }
}