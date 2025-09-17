//
//  BottomTabContent.swift
//  Icons
//
//  Created by Icons Team
//

import SwiftUI

/// 底部标签内容视图 - 根据选择的标签显示相应的内容
struct BottomTabContent: View {
    let selectedTab: BottomTab
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var interactionService: InteractionService

    var body: some View {
        Group {
            switch selectedTab {
            case .templates:
                TemplatesTabContent()
            case .sfSymbols:
                SFSymbolsTabContent()
            case .parameters:
                ParametersTabContent()
            }
        }
        .frame(maxHeight: 300) // 限制最大高度
        .padding(.horizontal)
    }
}

/// 模板标签内容
struct TemplatesTabContent: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var selectedCategory: TemplateCategory = .all

    // 简化版模板显示（只显示前几个）
    private var filteredTemplates: [PromptTemplate] {
        var templates = appState.templates

        // 分类筛选
        if selectedCategory != .all {
            templates = templates.filter { $0.category == selectedCategory }
        }

        // 搜索筛选
        if !searchText.isEmpty {
            templates = templates.filter { template in
                template.name.localizedCaseInsensitiveContains(searchText) ||
                template.description.localizedCaseInsensitiveContains(searchText) ||
                template.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return Array(templates.prefix(6)) // 只显示前6个模板
    }

    var body: some View {
        VStack(spacing: 12) {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("搜索模板...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)

            // 分类筛选
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TemplateCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            title: category.displayName,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }

            // 模板网格
            if filteredTemplates.isEmpty {
                EmptyStateView(
                    icon: "doc.text.magnifyingglass",
                    title: "未找到模板",
                    message: "尝试调整搜索条件"
                )
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(filteredTemplates) { template in
                        TemplateCard(template: template)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

/// SF符号标签内容
struct SFSymbolsTabContent: View {
    @State private var searchText = ""
    @State private var selectedCategory: SFSymbolCategory = .all

    // 示例SF符号数据
    private let sampleSymbols = [
        SFSymbolInfo(name: "square.and.arrow.up", category: .connectivity),
        SFSymbolInfo(name: "heart.fill", category: .shapes),
        SFSymbolInfo(name: "bell", category: .communication),
        SFSymbolInfo(name: "gear", category: .objects),
        SFSymbolInfo(name: "star.fill", category: .objects),
        SFSymbolInfo(name: "person.fill", category: .human)
    ]

    private var filteredSymbols: [SFSymbolInfo] {
        var symbols = sampleSymbols

        // 分类筛选
        if selectedCategory != .all {
            symbols = symbols.filter { $0.category == selectedCategory }
        }

        // 搜索筛选
        if !searchText.isEmpty {
            symbols = symbols.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return Array(symbols.prefix(6)) // 只显示前6个符号
    }

    var body: some View {
        VStack(spacing: 12) {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("搜索SF符号...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)

            // 分类筛选
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SFSymbolCategory.allCases.filter { $0 != .all }, id: \.self) { category in
                        CategoryChip(
                            title: category.displayName,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }

            // 符号网格
            if filteredSymbols.isEmpty {
                EmptyStateView(
                    icon: "square.grid.3x2.magnifyingglass",
                    title: "未找到符号",
                    message: "尝试调整搜索条件"
                )
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(filteredSymbols, id: \.name) { symbol in
                        SFSymbolCard(
                            symbol: symbol,
                            isSelected: false,
                            onClick: {},
                            onDoubleClick: {}
                        )
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

/// 参数标签内容
struct ParametersTabContent: View {
    @EnvironmentObject private var appState: AppState
    @State private var size: Int = 1024
    @State private var quality: String = "hd"
    @State private var removeBackground: Bool = true

    var body: some View {
        VStack(spacing: 16) {
            // 尺寸设置
            HStack {
                Text("尺寸")
                    .frame(width: 80, alignment: .leading)
                Stepper("\(size)px", value: $size, in: 256...2048, step: 256)
            }

            // 质量设置
            HStack {
                Text("质量")
                    .frame(width: 80, alignment: .leading)
                Picker("", selection: $quality) {
                    Text("标准").tag("standard")
                    Text("高清").tag("hd")
                    Text("超清").tag("ultra")
                }
                .pickerStyle(.segmented)
            }

            // 背景移除
            Toggle("移除背景", isOn: $removeBackground)

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

/// 模板卡片
struct TemplateCard: View {
    let template: PromptTemplate
    @State private var isHovered = false
    @EnvironmentObject private var interactionService: InteractionService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(template.name)
                .font(.headline)
                .lineLimit(1)

            Text(template.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Text(template.category.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)

                Spacer()

                Text("\(template.usageCount)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .onHover { hovering in
            withAnimation(interactionService.cardHoverAnimation()) {
                isHovered = hovering
            }
        }
    }
}


/// 空状态视图
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    BottomTabContent(selectedTab: .templates)
        .environmentObject(AppState.shared)
        .environmentObject(InteractionService.shared)
        .frame(height: 300)
}