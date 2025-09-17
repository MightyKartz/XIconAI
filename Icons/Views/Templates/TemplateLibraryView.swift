//
//  TemplateLibraryView.swift
//  Icons
//
//  Created by kartz on 2025/1/11.
//

import SwiftUI

/// 模板库视图
struct TemplateLibraryView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var selectedCategory: TemplateCategory = .all
    @State private var sortOption: TemplateSortOption = .name
    @State private var showingNewTemplateSheet = false
    @State private var showingImportSheet = false
    
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

        // 排序
        switch sortOption {
        case .name:
            templates.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .category:
            templates.sort { $0.category.displayName.localizedCaseInsensitiveCompare($1.category.displayName) == .orderedAscending }
        case .dateCreated:
            templates.sort { $0.createdAt > $1.createdAt }
        case .popularity:
            templates.sort { $0.usageCount > $1.usageCount }
        }

        return templates
    }

    // 获取有模板的分类
    private var activeCategories: [TemplateCategory] {
        let allCategories = TemplateCategory.allCases
        let templateCategories = Set(appState.templates.map { $0.category })

        // 只返回有模板的分类，包括"全部"
        return allCategories.filter { category in
            category == .all || templateCategories.contains(category)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            TemplateToolbarView(
                searchText: $searchText,
                selectedCategory: $selectedCategory,
                sortOption: $sortOption,
                showingNewTemplateSheet: $showingNewTemplateSheet,
                showingImportSheet: $showingImportSheet,
                activeCategories: activeCategories
            )
            
            Divider()
            
            // 模板网格
            if filteredTemplates.isEmpty {
                EmptyTemplateView(searchText: searchText, selectedCategory: selectedCategory)
            } else {
                TemplateGridView(templates: filteredTemplates)
            }
        }
        .navigationTitle("模板库")
        .sheet(isPresented: $showingNewTemplateSheet) {
            NewTemplateView()
        }
        .sheet(isPresented: $showingImportSheet) {
            ImportTemplateView()
        }
    }
}

/// 模板工具栏视图
struct TemplateToolbarView: View {
    @Binding var searchText: String
    @Binding var selectedCategory: TemplateCategory
    @Binding var sortOption: TemplateSortOption
    @Binding var showingNewTemplateSheet: Bool
    @Binding var showingImportSheet: Bool
    let activeCategories: [TemplateCategory]
    
    var body: some View {
        VStack(spacing: 6) {
            // 搜索和操作按钮
            HStack {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("搜索模板...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(4)

                Spacer()

                // 操作按钮
                HStack(spacing: 4) {
                    Button("新建") {
                        showingNewTemplateSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.caption)

                    Button("导入") {
                        showingImportSheet = true
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
            }

            // 筛选和排序
            HStack(spacing: 4) {
                // 分类筛选
                Picker("分类", selection: $selectedCategory) {
                    ForEach(activeCategories, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)

                Spacer()

                // 排序选项
                Menu {
                    ForEach(TemplateSortOption.allCases, id: \.self) { option in
                        Button(option.displayName) {
                            sortOption = option
                        }
                    }
                } label: {
                    HStack(spacing: 2) {
                        Text("排序: \(sortOption.displayName)")
                            .font(.caption)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                }
                .menuStyle(.borderlessButton)
            }
        }
        .padding(.horizontal, 8)
    }
}

/// 模板网格视图
struct TemplateGridView: View {
    let templates: [PromptTemplate]
    @EnvironmentObject private var appState: AppState

    private let columns = [
        GridItem(.adaptive(minimum: 120, maximum: 120), spacing: 10)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(templates) { template in
                    TemplateCardView(template: template)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
}

/// 模板卡片视图
struct TemplateCardView: View {
    let template: PromptTemplate
    @EnvironmentObject private var appState: AppState
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 模板名称
            Text(template.name)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // 底部信息行
            HStack(spacing: 4) {
                Text(template.category.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 2)
                    .padding(.vertical, 1)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(2)
                    .fixedSize()

                Spacer()

                // 使用次数
                if template.usageCount > 0 {
                    Text("\(template.usageCount)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fixedSize()
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .frame(width: 120, height: 120)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke((appState.selectedTemplate?.id == template.id ? Color.accentColor : (isHovered ? Color.accentColor.opacity(0.5) : Color.clear)), lineWidth: 2)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            selectTemplate()
        }
        .contextMenu {
            Button("编辑") {
                editTemplate()
            }

            Button("复制") {
                duplicateTemplate()
            }

            Divider()

            Button("删除", role: .destructive) {
                deleteTemplate()
            }
        }
        .help(template.description)
    }

    private func selectTemplate() {
        // 使用异步更新避免在视图更新期间发布状态变化
        Task { @MainActor in
            // 设置选中的模板
            appState.selectedTemplate = template

            // 增加使用次数
            appState.incrementTemplateUsage(template.id)
        }
    }

    private func editTemplate() {
        // TODO: 实现编辑模板功能
    }

    private func duplicateTemplate() {
        Task { @MainActor in
            let newTemplate = PromptTemplate(
                id: UUID(),
                name: "\(template.name) 副本",
                category: template.category,
                content: template.content,
                description: template.description,
                tags: template.tags,
                parameters: template.parameters,
                previewImage: template.previewImage,
                createdAt: Date(),
                updatedAt: Date(),
                isBuiltIn: false,
                popularity: 0,
                usageCount: 0,
                examples: template.examples
            )

            appState.saveTemplate(newTemplate)
        }
    }

    private func deleteTemplate() {
        Task { @MainActor in
            appState.deleteTemplate(template)
        }
    }
}

/// 空模板视图
struct EmptyTemplateView: View {
    let searchText: String
    let selectedCategory: TemplateCategory
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                if searchText.isEmpty {
                    Text("暂无模板")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("点击\"新建\"按钮创建您的第一个模板")
                        .foregroundColor(.secondary)
                } else {
                    Text("未找到匹配的模板")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("尝试调整搜索条件或分类筛选")
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 模板排序选项枚举
enum TemplateSortOption: String, CaseIterable {
    case name = "name"
    case category = "category"
    case dateCreated = "dateCreated"
    case popularity = "popularity"
    
    var displayName: String {
        switch self {
        case .name: return "名称"
        case .category: return "分类"
        case .dateCreated: return "创建时间"
        case .popularity: return "使用次数"
        }
    }
}

#Preview {
    TemplateLibraryView()
        .environmentObject(AppState.shared)
        .frame(width: 800, height: 600)
}