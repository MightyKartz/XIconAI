//
//  NavigationTab.swift
//  Icons Free Version - Navigation Tabs
//
//  Created by MightyKartz on 2024/11/18.
//

import Foundation

enum NavigationTab: String, CaseIterable, Identifiable {
    case home = "home"
    case generate = "generate"
    case history = "history"
    case settings = "settings"

    var id: String {
        return self.rawValue
    }

    var title: String {
        switch self {
        case .home:
            return "主页"
        case .generate:
            return "生成"
        case .history:
            return "历史"
        case .settings:
            return "设置"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .generate:
            return "sparkles"
        case .history:
            return "clock.fill"
        case .settings:
            return "gear"
        }
    }
}