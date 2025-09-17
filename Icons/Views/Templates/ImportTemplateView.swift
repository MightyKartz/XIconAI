//
//  ImportTemplateView.swift
//  Icons
//
//  Created by kartz on 2025/1/11.
//

import SwiftUI
import UniformTypeIdentifiers

/// 导入模板视图
struct ImportTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    @State private var importText = ""
    @State private var showingFilePicker = false
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("导入方式")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        Button("从文件导入") {
                            showingFilePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        
                        Text("或")
                            .foregroundColor(.secondary)
                        
                        Text("粘贴JSON内容")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("模板JSON")
                        .font(.headline)
                    
                    TextEditor(text: $importText)
                        .font(.system(.body, design: .monospaced))
                        .border(Color(.separatorColor))
                        .frame(minHeight: 200)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("导入模板")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("导入") {
                        importTemplate()
                    }
                    .disabled(importText.isEmpty)
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .alert("导入错误", isPresented: $showingError) {
            Button("确定") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let content = String(data: data, encoding: .utf8) ?? ""
                importText = content
            } catch {
                errorMessage = "读取文件失败: \(error.localizedDescription)"
                showingError = true
            }
            
        case .failure(let error):
            errorMessage = "选择文件失败: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func importTemplate() {
        guard !importText.isEmpty else { return }
        
        let data = importText.data(using: .utf8) ?? Data()
        
        // 尝试解析单个模板
        if let template = try? JSONDecoder().decode(PromptTemplate.self, from: data) {
            let importedTemplate = PromptTemplate(
                id: UUID(), // 生成新的ID
                name: template.name,
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
            
            appState.saveTemplate(importedTemplate)
            dismiss()
            return
        }
        
        // 尝试解析模板数组
        if let templates = try? JSONDecoder().decode([PromptTemplate].self, from: data) {
            for template in templates {
                let importedTemplate = PromptTemplate(
                    id: UUID(), // 生成新的ID
                    name: template.name,
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
                
                appState.saveTemplate(importedTemplate)
            }
            dismiss()
            return
        }
        
        errorMessage = "无法解析JSON格式，请检查内容是否正确"
        showingError = true
    }
}

#Preview {
    ImportTemplateView()
        .environmentObject(AppState.shared)
}