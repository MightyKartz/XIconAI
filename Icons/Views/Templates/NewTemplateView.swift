//
//  NewTemplateView.swift
//  Icons
//
//  Created by kartz on 2025/1/11.
//

import SwiftUI

/// 新建模板视图
struct NewTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    @State private var name = ""
    @State private var description = ""
    @State private var content = ""
    @State private var category: TemplateCategory = .modern
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var parameters: [TemplateParameter] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("模板名称", text: $name)
                    TextField("描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("分类", selection: $category) {
                        ForEach(TemplateCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                }
                
                Section("模板内容") {
                    TextField("Prompt模板", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                        .font(.system(.body, design: .monospaced))
                }
                
                Section("标签") {
                    HStack {
                        TextField("添加标签", text: $newTag)
                        Button("添加") {
                            addTag()
                        }
                        .disabled(newTag.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text(tag)
                                        Button("×") {
                                            removeTag(tag)
                                        }
                                        .foregroundColor(.red)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("新建模板")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveTemplate()
                    }
                    .disabled(name.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveTemplate() {
        let template = PromptTemplate(
            id: UUID(),
            name: name,
            category: category,
            content: content,
            description: description,
            tags: tags,
            parameters: parameters,
            previewImage: nil,
            createdAt: Date(),
            updatedAt: Date(),
            isBuiltIn: false,
            popularity: 0,
            usageCount: 0,
            examples: []
        )
        
        appState.saveTemplate(template)
        dismiss()
    }
}

#Preview {
    NewTemplateView()
        .environmentObject(AppState.shared)
}