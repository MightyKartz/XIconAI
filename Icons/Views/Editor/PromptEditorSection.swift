//
//  PromptEditorSection.swift
//  Icons
//
//  Created by Icons Team
//

import SwiftUI
import Combine

/// Prompt编辑器区域 - 包含对话框和生成按钮
struct PromptEditorSection: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var interactionService: InteractionService
    @Binding var isRightSidebarVisible: Bool

    @State private var promptText: String = ""
    @State private var isGenerating = false

    var body: some View {
        VStack(spacing: 16) {
            // Prompt文本编辑器
            TextEditor(text: $promptText)
                .frame(height: 100)
                .padding(6)
                .background(Color(.textBackgroundColor))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(.separatorColor), lineWidth: 1)
                )

            // 按钮区域
            HStack(spacing: 8) {
                Spacer()

                // 生成设置按钮 - 打开右侧侧边栏
                Button(action: {
                    withAnimation(interactionService.slideAnimation()) {
                        isRightSidebarVisible.toggle()
                    }
                    interactionService.buttonPressed()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "gear")
                        Text("生成设置")
                    }
                }
                .buttonStyle(.bordered)
                .font(.caption)

                // 生成按钮 (保持统一名称)
                Button(action: {
                    generateIcon()
                }) {
                    HStack(spacing: 4) {
                        if isGenerating {
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                        Text("生成")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGenerating || promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .font(.caption)
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            promptText = appState.currentPrompt
        }
        .onChangeCompat(of: promptText) { _ in
            // 使用异步更新避免在视图更新期间发布状态变化
            Task { @MainActor in
                appState.currentPrompt = promptText
            }
        }
    }

    private func generateIcon() {
        guard !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        isGenerating = true

        // 构建最终提示词，包含用户输入和选中的SF符号
        var finalPrompt = promptText
        if !appState.selectedSFSymbols.isEmpty {
            let symbolsString = appState.selectedSFSymbols.joined(separator: ", ")
            finalPrompt += " with symbols: \(symbolsString)"
        }

        // Log detailed information before generation
        print("=== Starting Icon Generation ===")
        print("Prompt: \(finalPrompt)")
        print("Selected Style: \(appState.selectedStyle.rawValue) - \(appState.selectedStyle.displayName)")
        print("Style Category: \(appState.selectedStyle.category.displayName)")
        print("Style Description: \(appState.selectedStyle.description)")
        print("Image Quality: \(appState.imageQuality.rawValue) - \(appState.imageQuality.displayName)")
        print("Remove Background: \(appState.removeBackground)")
        print("Generation Count: \(appState.generationCount)")
        print("Selected SF Symbols: \(appState.selectedSFSymbols.isEmpty ? "None" : appState.selectedSFSymbols.joined(separator: ", "))")

        // 使用实际的AI生成服务
        Task {
            do {
                if appState.enableBatchGeneration && appState.batchSize > 1 {
                    // 批量生成模式
                    print("=== Batch Icon Generation Started ===")
                    print("Batch generating icons with:")
                    print("  Prompt: \(finalPrompt)")
                    print("  Style: \(appState.selectedStyle.rawValue) - \(appState.selectedStyle.displayName)")
                    print("  Style Category: \(appState.selectedStyle.category.displayName)")
                    print("  Style Description: \(appState.selectedStyle.description)")
                    print("  Style Recommended Use: \(appState.selectedStyle.recommendedUse.joined(separator: ", "))")
                    print("  Style Suggested Colors: \(appState.selectedStyle.suggestedColors.joined(separator: ", "))")
                    print("  Quality: \(appState.imageQuality.rawValue) - \(appState.imageQuality.displayName)")
                    print("  Remove background: \(appState.removeBackground)")
                    print("  Batch size: \(appState.batchSize)")

                    // 创建多个相同的提示词
                    let prompts = Array(repeating: finalPrompt, count: appState.batchSize)

                    // Add SF symbols to parameters if any are selected
                    var generationParameters = GenerationParameters(
                        size: 1024,
                        quality: appState.imageQuality == .standard ? .standard : .hd,
                        removeBackground: appState.removeBackground,
                        symbols: appState.selectedSFSymbols.isEmpty ? nil : Array(appState.selectedSFSymbols)
                    )

                    print("Generation parameters:")
                    print("  Size: \(generationParameters.size)")
                    print("  Quality: \(generationParameters.quality.rawValue)")
                    print("  Remove Background: \(generationParameters.removeBackground)")
                    print("  Symbols: \(generationParameters.symbols?.joined(separator: ", ") ?? "None")")

                    let generatedIcons = try await AIGenerationService.shared.generateIcons(
                        prompts: prompts,
                        style: appState.selectedStyle,
                        parameters: generationParameters
                    )

                    await MainActor.run {
                        isGenerating = false
                        // 添加所有生成的图标
                        appState.generatedIcons.append(contentsOf: generatedIcons)
                        // 只显示本次生成的图标，清空之前的会话图标
                        appState.currentSessionIcons = generatedIcons
                        print("批量图标生成完成，共生成 \(generatedIcons.count) 个图标")
                        print("=== Batch Generation Completed ===")
                    }
                } else {
                    // 单个图标生成模式
                    print("=== Single Icon Generation Started ===")
                    print("Generating single icon with:")
                    print("  Prompt: \(finalPrompt)")
                    print("  Style: \(appState.selectedStyle.rawValue) - \(appState.selectedStyle.displayName)")
                    print("  Style Category: \(appState.selectedStyle.category.displayName)")
                    print("  Style Description: \(appState.selectedStyle.description)")
                    print("  Style Recommended Use: \(appState.selectedStyle.recommendedUse.joined(separator: ", "))")
                    print("  Style Suggested Colors: \(appState.selectedStyle.suggestedColors.joined(separator: ", "))")
                    print("  Quality: \(appState.imageQuality.rawValue) - \(appState.imageQuality.displayName)")
                    print("  Remove background: \(appState.removeBackground)")
                    print("  Generation count: \(appState.generationCount)")

                    // Add SF symbols to parameters if any are selected
                    var generationParameters = GenerationParameters(
                        size: 1024,
                        quality: appState.imageQuality == .standard ? .standard : .hd,
                        removeBackground: appState.removeBackground,
                        symbols: appState.selectedSFSymbols.isEmpty ? nil : Array(appState.selectedSFSymbols)
                    )

                    print("Generation parameters:")
                    print("  Size: \(generationParameters.size)")
                    print("  Quality: \(generationParameters.quality.rawValue)")
                    print("  Remove Background: \(generationParameters.removeBackground)")
                    print("  Symbols: \(generationParameters.symbols?.joined(separator: ", ") ?? "None")")

                    let generatedIcon = try await AIGenerationService.shared.generateIcon(
                        prompt: finalPrompt,
                        style: appState.selectedStyle,
                        parameters: generationParameters
                    )

                    await MainActor.run {
                        isGenerating = false
                        // 在实际应用中，这里会处理生成的图标结果
                        appState.generatedIcons.append(generatedIcon)
                        // 只显示本次生成的图标，清空之前的会话图标
                        appState.currentSessionIcons = [generatedIcon]
                        print("图标生成完成: \(finalPrompt)")
                        print("Generated icon ID: \(generatedIcon.id)")
                        print("=== Single Generation Completed ===")
                    }
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    // 处理错误
                    print("图标生成失败: \(error)")
                    print("Error details: \(error.localizedDescription)")
                    print("=== Generation Failed ===")
                }
            }
        }
    }
}

#Preview {
    PromptEditorSection(isRightSidebarVisible: .constant(false))
        .environmentObject(AppState.shared)
        .environmentObject(InteractionService.shared)
        .frame(width: 600, height: 200)
}