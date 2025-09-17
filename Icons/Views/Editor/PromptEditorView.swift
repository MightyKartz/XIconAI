//
//  PromptEditorView.swift
//  Icons
//
//  Created by kartz on 2025/1/11.
//

import SwiftUI
import Combine
import AppKit

/// Prompt编辑器视图
struct PromptEditorView: View {
    @EnvironmentObject private var appState: AppState
    // @StateObject private var templateService = TemplateService.shared
    @StateObject private var iconService = IconService.shared
    @StateObject private var apiService = APIService.shared
    @State private var promptText: String = ""
    @State private var selectedTemplate: PromptTemplate?
    @State private var parameterValues: [String: String] = [:]
    @State private var showingTemplateSelector = false
    @State private var showingParameterPanel = false
    @State private var isGenerating = false
    @State private var generationProgress: Double = 0.0
    @State private var showingPreview = false
    @State private var showAlert = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            EditorToolbarView(
                selectedTemplate: $selectedTemplate,
                showingTemplateSelector: $showingTemplateSelector,
                showingParameterPanel: $showingParameterPanel,
                onGenerate: generateIcon,
                isGenerating: isGenerating,
                canGenerate: !isGenerating
            )
            
            Divider()
            
            HStack(spacing: 0) {
                // 主编辑区域
                VStack(spacing: 0) {
                    // 模板信息栏
                    if let template = selectedTemplate {
                        TemplateInfoBar(template: template)
                        Divider()
                    }
                    
                    // 文本编辑器
                    PromptTextEditor(
                        text: $promptText,
                        selectedTemplate: selectedTemplate,
                        parameterValues: parameterValues
                    )
                }
                
                // 参数面板
                if showingParameterPanel && selectedTemplate != nil {
                    Divider()
                    
                    ParameterPanel(
                        template: selectedTemplate!,
                        parameterValues: $parameterValues,
                        onParameterChange: updatePromptWithParameters
                    )
                    .frame(width: 300)
                }
            }
            
            // 生成进度
            if isGenerating {
                Divider()
                GenerationProgressView(progress: generationProgress)
            }
        }
        .sheet(isPresented: $showingTemplateSelector) {
            TemplateSelectorSheet(
                selectedTemplate: $selectedTemplate,
                onTemplateSelected: { template in
                    selectTemplate(template)
                }
            )
        }
        .sheet(isPresented: $showingPreview) {
            if let template = selectedTemplate {
                TemplatePreviewView(template: template)
            }
        }
        .onAppear {
            loadInitialState()
        }
        .onChangeCompat(of: appState.selectedTemplate) { newTemplate in
            if let template = newTemplate {
                selectTemplate(template)
            }
        }
        .alert("无法生成", isPresented: $showAlert) {
            Button("好的", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadInitialState() {
        promptText = appState.currentPrompt
        selectedTemplate = appState.selectedTemplate
        
        if let template = selectedTemplate {
            initializeParameterValues(for: template)
        }
    }
    
    private func selectTemplate(_ template: PromptTemplate) {
        selectedTemplate = template
        promptText = template.content
        initializeParameterValues(for: template)
        updatePromptWithParameters()
        
        // 使用异步更新避免在视图更新期间发布状态变化
        Task { @MainActor in
            appState.selectedTemplate = template
            appState.currentPrompt = promptText
        }
    }
    
    private func initializeParameterValues(for template: PromptTemplate) {
        parameterValues.removeAll()
        for parameter in template.parameters {
            parameterValues[parameter.name] = parameter.defaultValue
        }
    }
    
    private func updatePromptWithParameters() {
        guard let template = selectedTemplate else { return }
        
        var updatedPrompt = template.content
        for (key, value) in parameterValues {
            let placeholder = "{\(key)}"
            updatedPrompt = updatedPrompt.replacingOccurrences(of: placeholder, with: value)
        }
        
        promptText = updatedPrompt
        
        // 使用异步更新避免在视图更新期间发布状态变化
        Task { @MainActor in
            appState.currentPrompt = promptText
        }
    }
    
    private func generateIcon() {
        guard !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "请输入 Prompt 内容后再生成。"
            showAlert = true
            return
        }

        isGenerating = true
        generationProgress = 0.0

        // Log detailed information before generation
        let style = appState.selectedStyle
        print("=== Starting Icon Generation in PromptEditorView ===")
        print("Prompt: \(promptText)")
        print("Selected Style: \(style.rawValue) - \(style.displayName)")
        print("Style Category: \(style.category.displayName)")
        print("Style Description: \(style.description)")

        Task {
            do {
                // 1) 配额校验
                print("Checking user quota...")
                let quota = try await apiService.getQuota()
                print("Quota info - Remaining: \(quota.remaining), Plan: \(quota.plan)")

                if quota.remaining <= 0 {
                    await MainActor.run {
                        isGenerating = false
                        generationProgress = 0.0
                        alertMessage = "配额不足。当前方案：\(quota.plan.uppercased())。请升级 Pro 以继续生成。"
                        showAlert = true
                        print("Generation failed: Insufficient quota")
                    }
                    return
                }

                // 2) 组织参数并创建生成任务
                let parameters: [String: Any] = [
                    "size": 1024,
                    "quality": "hd",
                    "removeBackground": true,
                    "style": style.rawValue
                ]

                print("Creating generation task with parameters:")
                for (key, value) in parameters {
                    print("  \(key): \(value)")
                }

                let taskId = try await apiService.createGenerationTask(
                    prompt: promptText,
                    style: style.rawValue,
                    parameters: parameters
                )
                print("Generation task created with ID: \(taskId)")

                // 3) 轮询任务状态
                var attempts = 0
                let maxAttempts = 120 // 最长约 2 分钟（1s 间隔）
                print("Starting to poll task status...")

                while attempts < maxAttempts {
                    try Task.checkCancellation()
                    // 间隔 1 秒
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    attempts += 1

                    let status = try await apiService.getTaskStatus(taskId: taskId)
                    print("Task status check #\(attempts): \(status.status), Progress: \(status.progress ?? 0.0)")

                    // 更新进度
                    await MainActor.run {
                        if let progress = status.progress {
                            generationProgress = min(max(progress, 0.0), 1.0)
                        } else {
                            // 未提供进度时，使用缓慢增长的占位进度
                            generationProgress = min(0.95, generationProgress + 0.02)
                        }
                    }

                    if status.status.lowercased() == "completed", let url = status.resultURL {
                        print("Task completed. Downloading image from: \(url)")
                        // 4) 下载图片并创建 GeneratedIcon
                        let generatedIcon = try await apiService.downloadImageAndCreateIcon(
                            imageURL: url,
                            prompt: promptText,
                            style: style.rawValue,
                            parameters: parameters
                        )
                        print("Generated icon downloaded and created successfully")

                        await MainActor.run {
                            iconService.addIcon(generatedIcon)
                            completeGeneration()
                            print("=== Icon Generation Completed Successfully ===")
                        }
                        return
                    } else if status.status.lowercased() == "failed" {
                        let errorMessage = status.error ?? "生成失败"
                        print("Task failed with error: \(errorMessage)")
                        throw APIError.serverError(code: 500, message: errorMessage)
                    }
                }

                // 超时
                print("Generation timed out after \(maxAttempts) attempts")
                throw APIError.serverError(code: 504, message: "生成超时，请稍后重试")

            } catch {
                await MainActor.run {
                    isGenerating = false
                    generationProgress = 0.0
                    alertMessage = "生成失败：\(error.iconsUserMessage)"
                    print("生成失败: \(error.iconsUserMessage)")
                    showAlert = true
                    print("生成失败: \(error.localizedDescription)")
                    print("=== Icon Generation Failed ===")
                }
            }
        }
    }
    
    private func completeGeneration() {
        isGenerating = false
        generationProgress = 0.0
        
        // 增加模板使用次数
        if var template = selectedTemplate {
            template.usageCount += 1
            appState.saveTemplate(template)
        }
    }
}

/// 编辑器工具栏
struct EditorToolbarView: View {
    @Binding var selectedTemplate: PromptTemplate?
    @Binding var showingTemplateSelector: Bool
    @Binding var showingParameterPanel: Bool
    let onGenerate: () -> Void
    let isGenerating: Bool
    let canGenerate: Bool
    
    var body: some View {
        HStack {
            // 模板选择
            Button(action: { showingTemplateSelector = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text")
                    Text(selectedTemplate?.name ?? "选择模板")
                }
            }
            .buttonStyle(.bordered)
            
            // 参数面板切换
            if selectedTemplate?.parameters.isEmpty == false {
                Button(action: { showingParameterPanel.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                        Text("参数")
                    }
                }
                .buttonStyle(.automatic)
            }
            
            Spacer()
            
            // 快捷操作
            HStack(spacing: 8) {
                Button("清空") {
                    clearEditor()
                }
                .buttonStyle(.bordered)
                
                Button("预览") {
                    // 预览功能
                }
                .buttonStyle(.bordered)
                .disabled(selectedTemplate == nil)
                
                Button("生成图标") {
                    onGenerate()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canGenerate)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
    
    private func clearEditor() {
        selectedTemplate = nil
        showingParameterPanel = false
    }
}

/// 模板信息栏
struct TemplateInfoBar: View {
    let template: PromptTemplate
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.headline)
                
                Text(template.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Label("\(template.parameters.count)", systemImage: "slider.horizontal.3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("\(template.usageCount)", systemImage: "chart.bar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.05))
    }
}

/// Prompt文本编辑器
struct PromptTextEditor: View {
    @Binding var text: String
    let selectedTemplate: PromptTemplate?
    let parameterValues: [String: String]
    @State private var highlightedText: AttributedString = AttributedString()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Prompt 内容")
                    .font(.headline)
                
                Spacer()
                
                Text("\(text.count) 字符")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                TextEditor(text: $text)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .background(Color(.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
                    .padding(.horizontal)
            }
        }
        .onChangeCompat(of: text) { _ in
            updateHighlighting()
        }
        .onChangeCompat(of: parameterValues) { _ in
            updateHighlighting()
        }
        .onAppear {
            updateHighlighting()
        }
    }
    
    private func updateHighlighting() {
        // 这里可以添加语法高亮逻辑
        highlightedText = AttributedString(text)
    }
}

/// 参数面板
struct ParameterPanel: View {
    let template: PromptTemplate
    @Binding var parameterValues: [String: String]
    let onParameterChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 面板标题
            HStack {
                Text("参数设置")
                    .font(.headline)
                
                Spacer()
                
                Button("重置") {
                    resetParameters()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            // 参数列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(template.parameters) { parameter in
                        ParameterInputView(
                            parameter: parameter,
                            value: Binding(
                                get: { parameterValues[parameter.name] ?? parameter.defaultValue },
                                set: { newValue in
                                    parameterValues[parameter.name] = newValue
                                    onParameterChange()
                                }
                            )
                        )
                    }
                }
                .padding()
            }
        }
        .background(Color(.windowBackgroundColor))
    }
    
    private func resetParameters() {
        for parameter in template.parameters {
            parameterValues[parameter.name] = parameter.defaultValue
        }
        onParameterChange()
    }
}

/// 参数输入视图
struct ParameterInputView: View {
    let parameter: TemplateParameter
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(parameter.name)
                    .font(.headline)
                
                if parameter.isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            
            if !parameter.placeholder.isEmpty {
                Text(parameter.placeholder)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 输入控件
            switch parameter.type {
            case .text:
                    if parameter.options?.isEmpty ?? true {
                        TextField("输入\(parameter.name)", text: $value)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Picker("选择\(parameter.name)", selection: $value) {
                            ForEach(parameter.options ?? [], id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                case .number:
                    TextField("输入数字", text: $value)
                        .textFieldStyle(.roundedBorder)
                    
                case .boolean:
                    Toggle(parameter.name, isOn: Binding(
                        get: { value.lowercased() == "true" },
                        set: { value = $0 ? "true" : "false" }
                    ))
                    
                case .color:
                    HStack {
                        TextField("颜色值", text: $value)
                            .textFieldStyle(.roundedBorder)
                        
                        ColorPicker("", selection: Binding(
                            get: {
                                if let color = try? Color(hex: value) {
                                    return color
                                }
                                return .blue
                            },
                            set: { newValue in
                                if let hex = newValue.toHex() {
                                    value = hex
                                }
                            }
                        ))
                        .labelsHidden()
                    }
                    
                default:
                    TextField("输入\(parameter.name)", text: $value)
                        .textFieldStyle(.roundedBorder)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}

/// 生成进度视图
struct GenerationProgressView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("正在生成图标...")
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
}

/// 模板选择器弹窗
struct TemplateSelectorSheet: View {
    @Binding var selectedTemplate: PromptTemplate?
    let onTemplateSelected: (PromptTemplate) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            TemplateLibraryView()
                .navigationTitle("选择模板")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("取消") {
                            dismiss()
                        }
                    }
                }
        }
        .frame(width: 800, height: 600)
    }
}


#Preview {
    PromptEditorView()
        .environmentObject(AppState.shared)
        .frame(width: 1000, height: 700)
}