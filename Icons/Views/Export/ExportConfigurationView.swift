//
//  ExportConfigurationView.swift
//  Icons
//
//  Created by Icons App on 2024/01/15.
//

import SwiftUI
import AppKit

/// 导出配置视图
struct ExportConfigurationView: View {
    let icons: [GeneratedIcon]
    let onExport: (ExportFormat, ExportSettings) -> Void
    
    // MARK: - 状态属性
    
    @State private var selectedFormat: ExportFormat = .png
    @State private var outputDirectory: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "")
    @State private var customSizes: [CGSize] = [CGSize(width: 1024, height: 1024)]
    @State private var includeOriginalSize = true
    @State private var createSubfolders = true
    @State private var filenameTemplate = "{prompt}_{style}_{size}"
    @State private var compressionQuality: Double = 0.9
    @State private var backgroundColor: Color = .clear
    @State private var addPadding = false
    @State private var paddingPercentage: Double = 10
    @State private var generateAppIconSet = false
    @State private var selectedPlatforms: Set<AppIconPlatform> = [.iOS]
    
    @State private var showingDirectoryPicker = false
    @State private var isExporting = false
    @State private var exportProgress: Double = 0
    
    // MARK: - 计算属性
    
    private var exportSettings: ExportSettings {
        ExportSettings(
            outputDirectory: outputDirectory,
            customSizes: customSizes,
            includeOriginalSize: includeOriginalSize,
            createSubfolders: createSubfolders,
            filenameTemplate: filenameTemplate,
            compressionQuality: compressionQuality,
            backgroundColor: backgroundColor,
            addPadding: addPadding,
            paddingPercentage: paddingPercentage,
            generateAppIconSet: generateAppIconSet,
            selectedPlatforms: selectedPlatforms
        )
    }
    
    private var estimatedFileCount: Int {
        var count = 0
        
        for _ in icons {
            if includeOriginalSize {
                count += 1
            }
            count += customSizes.count
            
            if generateAppIconSet {
                for platform in selectedPlatforms {
                    count += platform.sizeSpecs.count
                }
            }
        }
        
        return count
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 基本设置
                basicSettingsSection
                
                Divider()
                
                // 尺寸设置
                sizeSettingsSection
                
                Divider()
                
                // 文件设置
                fileSettingsSection
                
                Divider()
                
                // 外观设置
                appearanceSettingsSection
                
                Divider()
                
                // App Icon 设置
                appIconSettingsSection
                
                Divider()
                
                // 预览和导出
                exportSection
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 600)
        .fileImporter(
            isPresented: $showingDirectoryPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    outputDirectory = url
                }
            case .failure(let error):
                print("选择目录失败: \(error)")
            }
        }
    }
    
    // MARK: - 基本设置
    
    private var basicSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("基本设置")
                .font(.headline)
            
            // 导出格式
            VStack(alignment: .leading, spacing: 8) {
                Text("导出格式")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("导出格式", selection: $selectedFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        HStack {
                            Image(systemName: format.iconName)
                            Text(format.displayName)
                        }
                        .tag(format)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // 输出目录
            VStack(alignment: .leading, spacing: 8) {
                Text("输出目录")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(outputDirectory.path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer()
                    
                    Button("选择...") {
                        showingDirectoryPicker = true
                    }
                    .buttonStyle(.bordered)
                }
                .padding(8)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(6)
            }
        }
    }
    
    // MARK: - 尺寸设置
    
    private var sizeSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("尺寸设置")
                .font(.headline)
            
            // 包含原始尺寸
            Toggle("包含原始尺寸", isOn: $includeOriginalSize)
            
            // 自定义尺寸
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("自定义尺寸")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button("添加尺寸") {
                        customSizes.append(CGSize(width: 512, height: 512))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                ForEach(Array(customSizes.enumerated()), id: \.offset) { index, size in
                    HStack {
                        TextField("宽度", value: Binding(
                            get: { Int(customSizes[index].width) },
                            set: { customSizes[index].width = CGFloat($0) }
                        ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        
                        Text("×")
                            .foregroundColor(.secondary)
                        
                        TextField("高度", value: Binding(
                            get: { Int(customSizes[index].height) },
                            set: { customSizes[index].height = CGFloat($0) }
                        ), format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        
                        Text("px")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            customSizes.remove(at: index)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                        .disabled(customSizes.count <= 1)
                    }
                }
            }
            
            // 常用尺寸快捷按钮
            VStack(alignment: .leading, spacing: 8) {
                Text("常用尺寸")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                    ForEach(CommonSizes.allCases, id: \.self) { commonSize in
                        Button(commonSize.displayName) {
                            if !customSizes.contains(commonSize.size) {
                                customSizes.append(commonSize.size)
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .disabled(customSizes.contains(commonSize.size))
                    }
                }
            }
        }
    }
    
    // MARK: - 文件设置
    
    private var fileSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("文件设置")
                .font(.headline)
            
            // 创建子文件夹
            Toggle("为每个图标创建子文件夹", isOn: $createSubfolders)
            
            // 文件名模板
            VStack(alignment: .leading, spacing: 8) {
                Text("文件名模板")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("文件名模板", text: $filenameTemplate)
                    .textFieldStyle(.roundedBorder)
                
                Text("可用变量: {prompt}, {style}, {size}, {width}, {height}, {index}")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 压缩质量（仅对 PNG 有效）
            if selectedFormat == .png {
                VStack(alignment: .leading, spacing: 8) {
                    Text("压缩质量: \(Int(compressionQuality * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Slider(value: $compressionQuality, in: 0.1...1.0, step: 0.1)
                }
            }
        }
    }
    
    // MARK: - 外观设置
    
    private var appearanceSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("外观设置")
                .font(.headline)
            
            // 背景颜色
            VStack(alignment: .leading, spacing: 8) {
                Text("背景颜色")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    ColorPicker("背景颜色", selection: $backgroundColor, supportsOpacity: true)
                        .labelsHidden()
                        .frame(width: 40, height: 30)
                    
                    Text(backgroundColor == .clear ? "透明" : "自定义颜色")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("透明") {
                        backgroundColor = .clear
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("白色") {
                        backgroundColor = .white
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("黑色") {
                        backgroundColor = .black
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            // 添加内边距
            VStack(alignment: .leading, spacing: 8) {
                Toggle("添加内边距", isOn: $addPadding)
                
                if addPadding {
                    HStack {
                        Text("内边距: \(Int(paddingPercentage))%")
                            .font(.caption)
                        
                        Slider(value: $paddingPercentage, in: 5...25, step: 5)
                    }
                }
            }
        }
    }
    
    // MARK: - App Icon 设置
    
    private var appIconSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Icon 设置")
                .font(.headline)
            
            Toggle("生成 .appiconset 文件", isOn: $generateAppIconSet)
            
            if generateAppIconSet {
                VStack(alignment: .leading, spacing: 8) {
                    Text("目标平台")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(AppIconPlatform.allCases, id: \.self) { platform in
                        Toggle(platform.displayName, isOn: Binding(
                            get: { selectedPlatforms.contains(platform) },
                            set: { isSelected in
                                if isSelected {
                                    selectedPlatforms.insert(platform)
                                } else {
                                    selectedPlatforms.remove(platform)
                                }
                            }
                        ))
                    }
                }
            }
        }
    }
    
    // MARK: - 导出部分
    
    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("导出预览")
                .font(.headline)
            
            // 统计信息
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("图标数量:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(icons.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("预计文件数量:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(estimatedFileCount)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("输出格式:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(selectedFormat.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            .padding(8)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
            
            // 导出按钮
            HStack {
                Spacer()
                
                Button("取消") {
                    // 由父视图处理
                }
                .buttonStyle(.bordered)
                
                Button("开始导出") {
                    startExport()
                }
                .buttonStyle(.borderedProminent)
                .disabled(icons.isEmpty || isExporting)
            }
            
            // 导出进度
            if isExporting {
                VStack(alignment: .leading, spacing: 8) {
                    Text("正在导出...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: exportProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                }
            }
        }
    }
    
    // MARK: - 辅助方法
    
    private func startExport() {
        isExporting = true
        exportProgress = 0
        
        // 模拟导出进度
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            exportProgress += 0.1
            
            if exportProgress >= 1.0 {
                timer.invalidate()
                isExporting = false
                onExport(selectedFormat, exportSettings)
            }
        }
    }
}

// MARK: - 导出设置数据模型

struct ExportSettings {
    let outputDirectory: URL
    let customSizes: [CGSize]
    let includeOriginalSize: Bool
    let createSubfolders: Bool
    let filenameTemplate: String
    let compressionQuality: Double
    let backgroundColor: Color
    let addPadding: Bool
    let paddingPercentage: Double
    let generateAppIconSet: Bool
    let selectedPlatforms: Set<AppIconPlatform>
}

// MARK: - 常用尺寸枚举

enum CommonSizes: CaseIterable {
    case icon16, icon32, icon64, icon128, icon256, icon512, icon1024
    case web16, web32, web48, web64, web96, web128, web256
    case social512, social1024, social2048
    
    var size: CGSize {
        switch self {
        case .icon16: return CGSize(width: 16, height: 16)
        case .icon32: return CGSize(width: 32, height: 32)
        case .icon64: return CGSize(width: 64, height: 64)
        case .icon128: return CGSize(width: 128, height: 128)
        case .icon256: return CGSize(width: 256, height: 256)
        case .icon512: return CGSize(width: 512, height: 512)
        case .icon1024: return CGSize(width: 1024, height: 1024)
        case .web16: return CGSize(width: 16, height: 16)
        case .web32: return CGSize(width: 32, height: 32)
        case .web48: return CGSize(width: 48, height: 48)
        case .web64: return CGSize(width: 64, height: 64)
        case .web96: return CGSize(width: 96, height: 96)
        case .web128: return CGSize(width: 128, height: 128)
        case .web256: return CGSize(width: 256, height: 256)
        case .social512: return CGSize(width: 512, height: 512)
        case .social1024: return CGSize(width: 1024, height: 1024)
        case .social2048: return CGSize(width: 2048, height: 2048)
        }
    }
    
    var displayName: String {
        switch self {
        case .icon16: return "16×16"
        case .icon32: return "32×32"
        case .icon64: return "64×64"
        case .icon128: return "128×128"
        case .icon256: return "256×256"
        case .icon512: return "512×512"
        case .icon1024: return "1024×1024"
        case .web16: return "Web 16"
        case .web32: return "Web 32"
        case .web48: return "Web 48"
        case .web64: return "Web 64"
        case .web96: return "Web 96"
        case .web128: return "Web 128"
        case .web256: return "Web 256"
        case .social512: return "Social 512"
        case .social1024: return "Social 1024"
        case .social2048: return "Social 2048"
        }
    }
}

// MARK: - 扩展

extension ExportFormat {
    var iconName: String {
        switch self {
        case .png: return "photo"
        case .svg: return "doc.text"
        case .pdf: return "doc.richtext"
        case .icns: return "app.badge"
        case .ico: return "desktopcomputer"
        }
    }
}

// MARK: - 预览

#Preview {
    ExportConfigurationView(
        icons: [],
        onExport: { _, _ in }
    )
    .frame(width: 600, height: 800)
}