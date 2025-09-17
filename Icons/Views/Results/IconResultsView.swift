//
//  IconResultsView.swift
//  Icons
//
//  Created by Icons App on 2024/01/15.
//

import SwiftUI
import AppKit

/// 图标结果展示视图
struct IconResultsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var iconService = IconService.shared
    @StateObject private var exportService = ExportService.shared
    
    // MARK: - 状态属性
    
    @State private var selectedIcons: Set<UUID> = []
    @State private var showingExportSheet = false
    @State private var showingShareSheet = false
    @State private var showingDeleteAlert = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .newest
    @State private var filterOption: FilterOption = .all
    @State private var viewMode: ViewMode = .grid
    @State private var gridColumns = 4
    
    // MARK: - 计算属性
    
    private var filteredIcons: [GeneratedIcon] {
        var icons = iconService.generatedIcons
        
        // 搜索过滤
        if !searchText.isEmpty {
            icons = icons.filter { icon in
                icon.prompt.localizedCaseInsensitiveContains(searchText) ||
                icon.tags.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 类型过滤
        switch filterOption {
        case .all:
            break
        case .recent:
            let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
            icons = icons.filter { $0.createdAt >= oneWeekAgo }
        case .favorites:
            icons = icons.filter { $0.isFavorite }
        case .style(let style):
            icons = icons.filter { $0.tags.contains(style) }
        }
        
        // 排序
        switch sortOption {
        case .newest:
            icons.sort { $0.createdAt > $1.createdAt }
        case .oldest:
            icons.sort { $0.createdAt < $1.createdAt }
        case .name:
            icons.sort { $0.prompt < $1.prompt }
        case .style:
            icons.sort { $0.tags.first ?? "" < $1.tags.first ?? "" }
        }
        
        return icons
    }
    
    private var selectedIconsArray: [GeneratedIcon] {
        return filteredIcons.filter { selectedIcons.contains($0.id) }
    }
    
    // MARK: - 视图主体
    
    var body: some View {
        VStack(spacing: 0) {
            // 工具栏
            toolbar
            
            Divider()
            
            // 主内容区域
            if filteredIcons.isEmpty {
                emptyStateView
            } else {
                switch viewMode {
                case .grid:
                    gridView
                case .list:
                    listView
                }
            }
        }
        .navigationTitle("图标结果")
        .sheet(isPresented: $showingExportSheet) {
            exportSheet
        }
        .sheet(isPresented: $showingShareSheet) {
            shareSheet
        }
        .alert("删除确认", isPresented: $showingDeleteAlert) {
            Button("删除", role: .destructive) {
                deleteSelectedIcons()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("确定要删除选中的 \(selectedIcons.count) 个图标吗？")
        }
    }
    
    // MARK: - 工具栏
    
    private var toolbar: some View {
        VStack(spacing: 12) {
            // 第一行：搜索和视图控制
            HStack {
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("搜索图标...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
                .frame(maxWidth: 300)
                
                Spacer()
                
                // 视图模式切换
                Picker("视图模式", selection: $viewMode) {
                    Label("网格", systemImage: "grid")
                        .tag(ViewMode.grid)
                    Label("列表", systemImage: "list.bullet")
                        .tag(ViewMode.list)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 120)
                
                // 网格列数（仅在网格模式下显示）
                if viewMode == .grid {
                    Stepper("\(gridColumns) 列", value: $gridColumns, in: 2...6)
                        .frame(width: 100)
                }
            }
            
            // 第二行：筛选和排序
            HStack {
                // 筛选选项
                Menu {
                    Button("全部") { filterOption = .all }
                    Button("最近") { filterOption = .recent }
                    Button("收藏") { filterOption = .favorites }
                    
                    Divider()
                    
                    ForEach(IconStyle.allCases, id: \.self) { style in
                        Button(style.displayName) {
                            filterOption = .style(style.rawValue)
                        }
                    }
                } label: {
                    Label("筛选: \(filterOption.displayName)", systemImage: "line.3.horizontal.decrease.circle")
                }
                .menuStyle(BorderlessButtonMenuStyle())
                
                // 排序选项
                Menu {
                    Button("最新优先") { sortOption = .newest }
                    Button("最旧优先") { sortOption = .oldest }
                    Button("按名称") { sortOption = .name }
                    Button("按风格") { sortOption = .style }
                } label: {
                    Label("排序: \(sortOption.displayName)", systemImage: "arrow.up.arrow.down")
                }
                .menuStyle(BorderlessButtonMenuStyle())
                
                Spacer()
                
                // 选择信息
                if !selectedIcons.isEmpty {
                    Text("已选择 \(selectedIcons.count) 个图标")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 操作按钮
                HStack(spacing: 8) {
                    Button("全选") {
                        selectedIcons = Set(filteredIcons.map { $0.id })
                    }
                    .disabled(filteredIcons.isEmpty)
                    
                    Button("取消选择") {
                        selectedIcons.removeAll()
                    }
                    .disabled(selectedIcons.isEmpty)
                    
                    Button("导出") {
                        showingExportSheet = true
                    }
                    .disabled(selectedIcons.isEmpty)
                    
                    Button("分享") {
                        showingShareSheet = true
                    }
                    .disabled(selectedIcons.isEmpty)
                    
                    Button("删除") {
                        showingDeleteAlert = true
                    }
                    .disabled(selectedIcons.isEmpty)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.windowBackgroundColor))
    }
    
    // MARK: - 网格视图
    
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: gridColumns), spacing: 16) {
                ForEach(filteredIcons, id: \.id) { icon in
                    IconGridCard(
                        icon: icon,
                        isSelected: selectedIcons.contains(icon.id),
                        onSelectionChanged: { isSelected in
                            if isSelected {
                                selectedIcons.insert(icon.id)
                            } else {
                                selectedIcons.remove(icon.id)
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - 列表视图
    
    private var listView: some View {
        List(filteredIcons, id: \.id, selection: $selectedIcons) { icon in
            IconListRow(icon: icon)
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - 空状态视图
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("暂无图标")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(searchText.isEmpty ? "开始创建您的第一个图标" : "没有找到匹配的图标")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if searchText.isEmpty {
                Button("创建图标") {
                    // 使用异步更新避免在视图更新期间发布状态变化
                    Task { @MainActor in
                        appState.selectedTab = .generate
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("清除搜索") {
                    searchText = ""
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 导出表单
    
    private var exportSheet: some View {
        NavigationView {
            ExportConfigurationView(
                icons: selectedIconsArray,
                onExport: { format, settings in
                    Task {
                        await exportIcons(format: format, settings: settings)
                    }
                    showingExportSheet = false
                }
            )
            .navigationTitle("导出图标")

            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        showingExportSheet = false
                    }
                }
            }
        }
        .frame(width: 500, height: 400)
    }
    
    // MARK: - 分享表单
    
    private var shareSheet: some View {
        ShareSheet(items: selectedIconsArray.compactMap { icon -> Data? in
            if let localPath = icon.localPath {
                return try? Data(contentsOf: URL(fileURLWithPath: localPath))
            } else if let imageURL = URL(string: icon.imageURL) {
                return try? Data(contentsOf: imageURL)
            }
            return nil
        })
    }
    

    
    // MARK: - 辅助方法
    
    private func exportIcons(format: ExportFormat, settings: ExportSettings) async {
        do {
            // 分支1：生成 .appiconset/.iconset 按平台导出
            if settings.generateAppIconSet {
                for icon in selectedIconsArray {
                    for platform in settings.selectedPlatforms {
                        try await exportService.exportAsAppIconSet(
                            icon,
                            to: settings.outputDirectory,
                            platform: platform,
                            compressionQuality: settings.compressionQuality,
                            backgroundColor: settings.backgroundColor,
                            addPadding: settings.addPadding,
                            paddingPercentage: settings.paddingPercentage
                        )
                    }
                }
                return
            }
            
            // 分支2：导出 .icns（先生成 .iconset，然后 iconutil 转换）
            if format == .icns {
                for icon in selectedIconsArray {
                    try await exportService.exportAsICNS(
                        icon,
                        to: settings.outputDirectory,
                        compressionQuality: settings.compressionQuality,
                        backgroundColor: settings.backgroundColor,
                        addPadding: settings.addPadding,
                        paddingPercentage: settings.paddingPercentage
                    )
                }
                return
            }
            
            // 分支3：常规按所选格式导出文件
            for icon in selectedIconsArray {
                // 计算导出目录：是否为该图标创建子目录
                let baseFolderURL: URL = {
                    if settings.createSubfolders {
                        let folderName = ExportService.sanitizeFileName(icon.prompt.isEmpty ? icon.id.uuidString : icon.prompt)
                        return settings.outputDirectory.appendingPathComponent(folderName)
                    } else {
                        return settings.outputDirectory
                    }
                }()
                // 确保目录存在
                try? FileManager.default.createDirectory(at: baseFolderURL, withIntermediateDirectories: true)

                // 组装需要导出的尺寸列表（.zero 表示原始尺寸的占位）
                var sizes: [CGSize] = []
                if settings.includeOriginalSize {
                    sizes.append(.zero)
                }
                // 去重自定义尺寸（按整数宽高）
                let uniqueCustom = settings.customSizes.reduce(into: Set<String>()) { partial, sz in
                    partial.insert("\(Int(sz.width))x\(Int(sz.height))")
                }
                for key in uniqueCustom {
                    let comps = key.split(separator: "x")
                    if comps.count == 2, let w = Int(comps[0]), let h = Int(comps[1]) {
                        sizes.append(CGSize(width: w, height: h))
                    }
                }

                // 生成文件名并导出
                for (idx, sz) in sizes.enumerated() {
                    // 文件名占位变量
                    let styleValue = icon.parameters["style"] ?? "default"
                    let isOriginal = sz == .zero
                    let widthStr = isOriginal ? "" : String(Int(sz.width))
                    let heightStr = isOriginal ? "" : String(Int(sz.height))
                    let sizeStr = isOriginal ? "original" : "\(widthStr)x\(heightStr)"

                    // 生成文件名（根据模板替换占位符）
                    var name = settings.filenameTemplate
                        .replacingOccurrences(of: "{prompt}", with: icon.prompt)
                        .replacingOccurrences(of: "{style}", with: styleValue)
                        .replacingOccurrences(of: "{size}", with: sizeStr)
                        .replacingOccurrences(of: "{width}", with: widthStr)
                        .replacingOccurrences(of: "{height}", with: heightStr)
                        .replacingOccurrences(of: "{index}", with: String(idx + 1))
                    name = ExportService.sanitizeFileName(name)
                    if name.isEmpty { name = icon.id.uuidString }

                    let fileURL = baseFolderURL.appendingPathComponent("\(name).\(format.fileExtension)")

                    if isOriginal {
                        try await exportService.exportIcon(
                            icon,
                            to: fileURL,
                            format: format,
                            size: nil,
                            compressionQuality: settings.compressionQuality,
                            backgroundColor: settings.backgroundColor,
                            addPadding: settings.addPadding,
                            paddingPercentage: settings.paddingPercentage
                        )
                    } else {
                        try await exportService.exportIcon(
                            icon,
                            to: fileURL,
                            format: format,
                            size: sz,
                            compressionQuality: settings.compressionQuality,
                            backgroundColor: settings.backgroundColor,
                            addPadding: settings.addPadding,
                            paddingPercentage: settings.paddingPercentage
                        )
                    }
                }
            }
        } catch {
            print("导出失败: \(error)")
        }
    }
    
    private func deleteSelectedIcons() {
        for iconId in selectedIcons {
            // TODO: 实现删除图标功能
            print("删除图标: \(iconId)")
        }
        selectedIcons.removeAll()
    }
}

// MARK: - 图标网格卡片

struct IconGridCard: View {
    let icon: GeneratedIcon
    let isSelected: Bool
    let onSelectionChanged: (Bool) -> Void

    @State private var isHovered = false
    @State private var showingPreview = false
    @AppStorage("showThumbnails") private var showThumbnails: Bool = true

    private var nsImageToShow: NSImage? {
        if showThumbnails, let thumb = icon.thumbnailPath, let img = NSImage(contentsOfFile: thumb) {
            return img
        }
        if let local = icon.localPath, let img = NSImage(contentsOfFile: local) {
            return img
        }
        return nil
    }

    var body: some View {
        CardView(
            content: {
                VStack(alignment: .leading, spacing: 8) {
                    // 图标图像
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.controlBackgroundColor))
                            .aspectRatio(1, contentMode: .fit)

                        if let image = nsImageToShow {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(8)
                        } else {
                            AsyncImage(url: URL(string: icon.imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .padding(8)
                        }

                        // 选择覆盖层
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentColor, lineWidth: 3)

                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                        .background(Color.white, in: Circle())
                                }
                                Spacer()
                            }
                            .padding(8)
                        }

                        // 悬停覆盖层
                        if isHovered {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.1))

                            VStack {
                                Spacer()
                                HStack(spacing: 8) {
                                    Button(action: { showingPreview = true }) {
                                        Image(systemName: "eye")
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)

                                    Button(action: { copyToClipboard() }) {
                                        Image(systemName: "doc.on.doc")
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)

                                    Button(action: { toggleFavorite() }) {
                                        Image(systemName: icon.isFavorite ? "heart.fill" : "heart")
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                                .padding(8)
                            }
                        }
                    }
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isHovered = hovering
                        }
                    }
                    .onTapGesture {
                        onSelectionChanged(!isSelected)
                    }

                    // 图标信息
                    VStack(alignment: .leading, spacing: 4) {
                        Text(icon.prompt)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(2)

                        HStack {
                            Text(icon.parameters["style"]?.capitalized ?? "未知风格")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text(formatDate(icon.createdAt))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        )
        .sheet(isPresented: $showingPreview) {
            IconPreviewSheet(icon: icon)
        }
    }

    private func copyToClipboard() {
        var image: NSImage?

        if let localPath = icon.localPath {
            image = NSImage(contentsOfFile: localPath)
        }

        guard let image = image else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }

    private func toggleFavorite() {
        // TODO: 实现收藏功能
        print("切换收藏状态: \(icon.id)")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - 图标列表行

struct IconListRow: View {
    let icon: GeneratedIcon
    @AppStorage("showThumbnails") private var showThumbnails: Bool = true
    
    private var nsImageToShow: NSImage? {
        if showThumbnails, let thumb = icon.thumbnailPath, let img = NSImage(contentsOfFile: thumb) {
            return img
        }
        if let local = icon.localPath, let img = NSImage(contentsOfFile: local) {
            return img
        }
        return nil
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 缩略图
            if let image = nsImageToShow {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(6)
            } else {
                AsyncImage(url: URL(string: icon.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 40, height: 40)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(6)
            }
            
            // 信息
            VStack(alignment: .leading, spacing: 2) {
                Text(icon.prompt)
                    .font(.body)
                    .lineLimit(1)
                
                HStack {
                    Text(icon.parameters["style"]?.capitalized ?? "未知风格")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatDate(icon.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 操作按钮
            HStack(spacing: 8) {
                Button(action: { copyToClipboard() }) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button(action: { toggleFavorite() }) {
                    Image(systemName: icon.isFavorite ? "heart.fill" : "heart")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func copyToClipboard() {
        var image: NSImage?
        
        if let localPath = icon.localPath {
            image = NSImage(contentsOfFile: localPath)
        } else if let url = URL(string: icon.imageURL) {
            // TODO: 异步加载网络图片
            print("需要异步加载网络图片: \(url)")
            return
        }
        
        guard let image = image else { return }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
    
    private func toggleFavorite() {
        // TODO: 实现收藏功能
        print("切换收藏状态: \(icon.id)")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - 枚举定义

enum ViewMode: String, CaseIterable {
    case grid = "grid"
    case list = "list"
}

enum SortOption: String, CaseIterable {
    case newest = "newest"
    case oldest = "oldest"
    case name = "name"
    case style = "style"
    
    var displayName: String {
        switch self {
        case .newest: return "最新优先"
        case .oldest: return "最旧优先"
        case .name: return "按名称"
        case .style: return "按风格"
        }
    }
}

enum FilterOption: Equatable {
    case all
    case recent
    case favorites
    case style(String)
    
    var displayName: String {
        switch self {
        case .all: return "全部"
        case .recent: return "最近"
        case .favorites: return "收藏"
        case .style(let style): return style.capitalized
        }
    }
}

// MARK: - 辅助视图

struct IconPreviewSheet: View {
    let icon: GeneratedIcon
    
    var body: some View {
        VStack(spacing: 16) {
            if let localPath = icon.localPath, let image = NSImage(contentsOfFile: localPath) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 400, maxHeight: 400)
            } else {
                AsyncImage(url: URL(string: icon.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: 400, maxHeight: 400)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(icon.prompt)
                    .font(.headline)
                
                HStack {
                    Text("风格: \(icon.parameters["style"]?.capitalized ?? "未知")")
                    Spacer()
                    Text("创建时间: \(formatDate(icon.createdAt))")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(width: 500, height: 600)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ShareSheet: NSViewRepresentable {
    let items: [Data]
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        DispatchQueue.main.async {
            let sharingService = NSSharingServicePicker(items: items)
            sharingService.show(relativeTo: .zero, of: view, preferredEdge: .minY)
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

// MARK: - 预览

#Preview {
    IconResultsView()
        .environmentObject(AppState.shared)
        .frame(width: 1000, height: 700)
}