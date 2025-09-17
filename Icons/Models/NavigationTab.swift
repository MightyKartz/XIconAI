//
//  NavigationTab.swift
//  Icons
//
//  Created by Icons Team
//

import Foundation
import SwiftUI

/// 导航标签页枚举
enum NavigationTab: String, CaseIterable, Identifiable {
    case generate = "generate"
    case editor = "editor"
    case templates = "templates"
    case sfSymbols = "sfSymbols"
    case results = "results"
    case history = "history"
    case settings = "settings"
    case liquidGlass = "liquidGlass"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .generate:
            return "生成"
        case .editor:
            return "编辑器"
        case .templates:
            return "模板"
        case .sfSymbols:
            return "SF 符号"
        case .results:
            return "结果"
        case .history:
            return "历史"
        case .settings:
            return "设置"
        case .liquidGlass:
            return "Liquid Glass"
        }
    }
    
    var title: String {
        return displayName
    }
    
    var icon: String {
        switch self {
        case .generate:
            return "wand.and.stars"
        case .editor:
            return "square.and.pencil"
        case .templates:
            return "doc.text.image"
        case .sfSymbols:
            return "app.badge"
        case .results:
            return "photo.stack"
        case .history:
            return "clock.arrow.circlepath"
        case .settings:
            return "gear"
        case .liquidGlass:
            return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .generate:
            return .purple
        case .editor:
            return .blue
        case .templates:
            return .green
        case .sfSymbols:
            return .orange
        case .results:
            return .pink
        case .history:
            return .gray
        case .settings:
            return .secondary
        case .liquidGlass:
            return .blue
        }
    }
}