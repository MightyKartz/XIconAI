//
//  GenerateView.swift
//  Icons Free Version - Generate View
//
//  Created by MightyKartz on 2024/11/18.
//

import SwiftUI

struct GenerateView: View {
    @ObservedObject var appState: AppState
    @State private var prompt: String = ""
    @State private var style: String = ""
    @State private var size: String = "1024x1024"
    @State private var quality: String = "standard"
    @State private var count: Int = 1
    @State private var isGenerating = false
    @State private var showingResult = false
    @State private var currentResult: GenerationResult?

    private let availableSizes = ["512x512", "1024x1024", "1328x1328"]
    private let availableQualities = ["standard", "hd"]
    private let availableStyles = ["natural", "vivid", "realistic", "cartoon", "minimalist", "flat"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 检查配置状态
                if !appState.isConfigured {
                    configurationPrompt
                } else {
                    generationForm
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("生成图标")
        .disabled(isGenerating)
        .sheet(isPresented: $showingResult) {
            if let result = currentResult {
                ResultView(result: result)
            }
        }
    }

    // MARK: - Configuration Prompt

    private var configurationPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("需要配置API")
                .font(.title2)
                .fontWeight(.semibold)

            Text("请先在设置中配置AI提供商API密钥")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("前往设置") {
                // TODO: 导航到设置页面
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Generation Form

    private var generationForm: some View {
        VStack(spacing: 24) {
            // 提示词输入
            VStack(alignment: .leading, spacing: 12) {
                Text("图标描述")
                    .font(.headline)
                    .fontWeight(.medium)

                TextField("描述您想要的图标，例如：一个现代简约的相机图标", text: $prompt, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)

                Text("详细描述能帮助AI生成更符合您需求的图标")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 样式选择
            VStack(alignment: .leading, spacing: 12) {
                Text("样式")
                    .font(.headline)
                    .fontWeight(.medium)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(availableStyles, id: \.self) { styleOption in
                            StyleChip(
                                title: styleOption.capitalized,
                                isSelected: style == styleOption,
                                action: { style = styleOption }
                            )
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }

            // 尺寸和质量
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("尺寸")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Picker("尺寸", selection: $size) {
                        ForEach(availableSizes, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                    .buttonStyle(.bordered)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("质量")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Picker("质量", selection: $quality) {
                        ForEach(availableQualities, id: \.self) { quality in
                            Text(quality.capitalized).tag(quality)
                        }
                    }
                    .pickerStyle(.menu)
                    .buttonStyle(.bordered)
                }
            }

            // 生成数量
            VStack(alignment: .leading, spacing: 8) {
                Text("数量: \(count)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Stepper("", value: $count, in: 1...4)
                    .frame(maxWidth: .infinity)
            }

            // 生成按钮
            Button(action: generateIcon) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("生成中...")
                    } else {
                        Image(systemName: "sparkles")
                        Text("生成图标")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canGenerate ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!canGenerate || isGenerating)

            // 历史记录预览
            if !appState.generationHistory.isEmpty {
                historyPreview
            }
        }
    }

    // MARK: - History Preview

    private var historyPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近生成")
                .font(.headline)
                .fontWeight(.medium)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(Array(appState.generationHistory.prefix(6))) { result in
                    HistoryItem(result: result) {
                        currentResult = result
                        showingResult = true
                    }
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var canGenerate: Bool {
        return !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions

    private func generateIcon() {
        guard let config = appState.apiConfig else { return }

        isGenerating = true

        Task {
            do {
                let request = GenerationRequest(
                    prompt: prompt.trimmingCharacters(in: .whitespacesAndNewlines),
                    style: style.isEmpty ? nil : style,
                    size: size,
                    quality: quality == "standard" ? nil : quality,
                    provider: config.provider,
                    model: config.model,
                    count: count
                )

                let provider = AIProviderFactory.createProvider(for: config.provider, config: config)
                let result = try await provider.generateImage(request: request)

                await MainActor.run {
                    appState.addToHistory(result)
                    currentResult = result
                    showingResult = true
                    isGenerating = false
                }

            } catch {
                await MainActor.run {
                    appState.handleError(error)
                    isGenerating = false
                }
            }
        }
    }
}

// MARK: - Style Chip

struct StyleChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - History Item

struct HistoryItem: View {
    let result: GenerationResult
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                if let imageData = result.imageData,
                   let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: result.isSuccessful ? "photo" : "exclamationmark.triangle")
                                .foregroundColor(result.isSuccessful ? .primary : .red)
                        )
                }

                Text(result.provider.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Result View

struct ResultView: View {
    let result: GenerationResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 图像显示
                if let imageData = result.imageData,
                   let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .overlay(
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                                Text(result.errorMessage ?? "生成失败")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                        )
                }

                // 信息显示
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(title: "提供商", value: result.provider.displayName)
                    InfoRow(title: "模型", value: result.model)
                    InfoRow(title: "处理时间", value: String(format: "%.2f秒", result.processingTime))
                    InfoRow(title: "状态", value: result.isSuccessful ? "成功" : "失败")

                    if !result.prompt.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("提示词")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(result.prompt)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(8)
                        }
                    }
                }

                Spacer()

                // 操作按钮
                HStack(spacing: 12) {
                    Button("关闭") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)

                    if result.isSuccessful, let imageData = result.imageData {
                        Button("保存") {
                            saveImage(imageData)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationTitle("生成结果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveImage(_ imageData: Data) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.nameFieldStringValue = "icon_\(UUID().uuidString.prefix(8)).png"

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try imageData.write(to: url)
                } catch {
                    print("保存失败: \(error)")
                }
            }
        }
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        GenerateView(appState: AppState())
    }
}