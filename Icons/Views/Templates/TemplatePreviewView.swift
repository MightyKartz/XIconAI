//
//  TemplatePreviewView.swift
//  Icons
//
//  Created by kartz on 2025/1/11.
//

import SwiftUI

/// 模板预览视图
struct TemplatePreviewView: View {
    let template: PromptTemplate
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: PreviewTab = .content
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 头部信息
                TemplateHeaderView(template: template)
                
                Divider()
                
                // 标签页选择
                Picker("预览选项", selection: $selectedTab) {
                    ForEach(PreviewTab.allCases, id: \.self) { tab in
                        Text(tab.displayName).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 内容区域
                TabView(selection: $selectedTab) {
                    TemplateContentView(template: template)
                        .tag(PreviewTab.content)
                    
                    TemplateParametersView(template: template)
                        .tag(PreviewTab.parameters)
                    
                    TemplateExamplesView(template: template)
                        .tag(PreviewTab.examples)
                    
                    TemplateMetadataView(template: template)
                        .tag(PreviewTab.metadata)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
            }
            .navigationTitle(template.name)
            // .navigationBarTitleDisplayMode(.inline) // macOS 不支持
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("使用模板") {
                        useTemplate()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(width: 700, height: 600)
    }
    
    private func useTemplate() {
        // 使用异步更新避免在视图更新期间发布状态变化
        Task { @MainActor in
            appState.selectedTemplate = template
            appState.currentPrompt = template.content
            appState.selectedTab = .generate
            
            // 增加使用次数
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
                updatedAt: Date(),
                isBuiltIn: template.isBuiltIn,
                popularity: template.popularity,
                usageCount: template.usageCount + 1,
                examples: template.examples
            )
            appState.saveTemplate(updatedTemplate)
        }
        
        dismiss()
    }
}

/// 预览标签页枚举
enum PreviewTab: String, CaseIterable {
    case content = "content"
    case parameters = "parameters"
    case examples = "examples"
    case metadata = "metadata"
    
    var displayName: String {
        switch self {
        case .content: return "内容"
        case .parameters: return "参数"
        case .examples: return "示例"
        case .metadata: return "信息"
        }
    }
}

/// 模板头部视图
struct TemplateHeaderView: View {
    let template: PromptTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(template.category.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("使用 \(template.usageCount) 次")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(template.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(template.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            // 标签
            if !template.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(template.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
}

/// 模板内容视图
struct TemplateContentView: View {
    let template: PromptTemplate
    @State private var highlightedContent: AttributedString = AttributedString()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Prompt 内容")
                    .font(.headline)
                
                Text(highlightedContent)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
                
                HStack {
                    Text("字符数: \(template.content.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("复制内容") {
                        copyContent()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .onAppear {
            highlightParameters()
        }
    }
    
    private func highlightParameters() {
        var attributedString = AttributedString(template.content)
        
        // 高亮参数占位符
        for parameter in template.parameters {
            let placeholder = "{\(parameter.name)}"
            if let range = attributedString.range(of: placeholder) {
                attributedString[range].foregroundColor = .blue
                attributedString[range].font = .system(size: 14, weight: .bold, design: .default)
            }
        }
        
        highlightedContent = attributedString
    }
    
    private func copyContent() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(template.content, forType: .string)
    }
}

/// 模板参数视图
struct TemplateParametersView: View {
    let template: PromptTemplate
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("参数列表")
                    .font(.headline)
                
                if template.parameters.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        
                        Text("此模板没有参数")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(template.parameters) { parameter in
                            ParameterCardView(parameter: parameter)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

/// 参数卡片视图
struct ParameterCardView: View {
    let parameter: TemplateParameter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(parameter.name)
                    .font(.headline)
                
                Spacer()
                
                Text(parameter.type.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
                
                if parameter.isRequired {
                    Text("必填")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            }
            
            if !parameter.displayName.isEmpty {
                Text(parameter.displayName)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            if !parameter.defaultValue.isEmpty {
                HStack {
                    Text("默认值:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(parameter.defaultValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            
            if let options = parameter.options, !options.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("可选值:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(options, id: \.self) { option in
                                Text(option)
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color(.controlBackgroundColor))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}

/// 模板示例视图
struct TemplateExamplesView: View {
    let template: PromptTemplate
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("使用示例")
                    .font(.headline)
                
                if template.examples.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        
                        Text("暂无示例")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(template.examples.enumerated()), id: \.offset) { index, example in
                            ExampleCardView(example: example, index: index + 1)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

/// 示例卡片视图
struct ExampleCardView: View {
    let example: String
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("示例 \(index)")
                    .font(.headline)
                
                Spacer()
                
                Button("复制") {
                    copyExample()
                }
                .buttonStyle(.bordered)
            }
            
            Text(example)
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color(.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separatorColor), lineWidth: 1)
                )
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private func copyExample() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(example, forType: .string)
    }
}

/// 模板元数据视图
struct TemplateMetadataView: View {
    let template: PromptTemplate
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("模板信息")
                    .font(.headline)
                
                VStack(spacing: 16) {
                    MetadataRowView(title: "ID", value: template.id.uuidString)
                    MetadataRowView(title: "名称", value: template.name)
                    MetadataRowView(title: "分类", value: template.category.displayName)
                    MetadataRowView(title: "创建时间", value: DateFormatter.localizedString(from: template.createdAt, dateStyle: .medium, timeStyle: .short))
                    MetadataRowView(title: "使用次数", value: "\(template.usageCount)")
                    MetadataRowView(title: "参数数量", value: "\(template.parameters.count)")
                    MetadataRowView(title: "示例数量", value: "\(template.examples.count)")
                    MetadataRowView(title: "内容长度", value: "\(template.content.count) 字符")
                }
            }
            .padding()
        }
    }
}

/// 元数据行视图
struct MetadataRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TemplatePreviewView(template: PromptTemplate(
        id: UUID(),
        name: "现代简约图标",
        category: .business,
        content: "Create a {style} icon for a {app_type} app with {color_scheme} colors",
        description: "生成现代简约风格的应用图标",
        tags: ["现代", "简约"],
        parameters: [
            TemplateParameter(
                name: "style",
                displayName: "图标风格",
                type: .text,
                defaultValue: "modern minimalist",
                placeholder: "modern minimalist",
                isRequired: true,
                options: ["modern minimalist", "flat design", "gradient"]
            ),
            TemplateParameter(
                name: "app_type",
                displayName: "应用类型",
                type: .text,
                defaultValue: "productivity",
                placeholder: "productivity",
                isRequired: true,
                options: ["productivity", "social", "gaming", "utility"]
            )
        ],
        previewImage: nil,
        createdAt: Date(),
        updatedAt: Date(),
        isBuiltIn: true,
        popularity: 0,
        usageCount: 0,
        examples: [
            "Create a modern minimalist icon for a productivity app with blue and white colors",
            "Create a flat design icon for a social app with vibrant colors"
        ]
    ))
    .environmentObject(AppState.shared)
}