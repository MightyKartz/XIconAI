//
//  SFSymbolsView.swift
//  Icons
//
//  Created by Icons App on 2024/01/15.
//

import SwiftUI

/// SF Symbols 浏览和搜索视图
struct SFSymbolsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var selectedCategory: SFSymbolCategory = .all
    @State private var selectedSymbol: String?
    @State private var showingSymbolDetail = false
    @State private var symbols: [SFSymbolInfo] = []
    @State private var filteredSymbols: [SFSymbolInfo] = []
    @State private var isLoading = true
    
    private let columns = Array(repeating: GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 12), count: 6)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索和筛选栏
                searchAndFilterBar
                
                Divider()
                
                // 顶部操作区（替代 toolbar）
                HStack {
                    Spacer()
                    Button("插入到编辑器") {
                        insertSelectedSymbol()
                    }
                    .disabled(selectedSymbol == nil)
                }
                .padding([.horizontal, .top])
                
                // 符号网格
                if isLoading {
                    loadingView
                } else if filteredSymbols.isEmpty {
                    emptyStateView
                } else {
                    symbolsGrid
                }
            }
            .navigationTitle("SF Symbols")
            // .navigationBarTitleDisplayMode(.large) // macOS 不支持
            // 已移除 .toolbar 以避免重载歧义
        }
        .sheet(isPresented: $showingSymbolDetail) {
            if let symbol = selectedSymbol {
                SFSymbolDetailView(symbolName: symbol)
            }
        }
        .task {
            await loadSymbols()
        }
        .onChangeCompat(of: searchText) { _ in
            filterSymbols()
        }
        .onChangeCompat(of: selectedCategory) { _ in
            filterSymbols()
        }
     }
 
     // MARK: - 搜索和筛选栏
     
     private var searchAndFilterBar: some View {
         VStack(spacing: 12) {
             // 搜索框
             HStack {
                 Image(systemName: "magnifyingglass")
                     .foregroundColor(.secondary)
                
                 TextField("搜索 SF Symbols...", text: $searchText)
                     .textFieldStyle(.plain)
                
                 if !searchText.isEmpty {
                     Button("清除") {
                         searchText = ""
                     }
                     .foregroundColor(.secondary)
                 }
             }
             .padding(.horizontal, 12)
             .padding(.vertical, 8)
             .background(Color(.controlBackgroundColor))
             .cornerRadius(8)
             
             // 分类筛选
             ScrollView(.horizontal, showsIndicators: false) {
                 HStack(spacing: 8) {
                     ForEach(SFSymbolCategory.allCases, id: \.self) { category in
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
         }
         .padding()
     }
     
     // MARK: - 符号网格
     
     private var symbolsGrid: some View {
         ScrollView {
             LazyVGrid(columns: columns, spacing: 12) {
                 ForEach(filteredSymbols, id: \.name) { symbol in
                     SFSymbolCard(
                         symbol: symbol,
                         isSelected: selectedSymbol == symbol.name
                     ) {
                         selectedSymbol = symbol.name
                     } onDoubleClick: {
                         selectedSymbol = symbol.name
                         showingSymbolDetail = true
                     }
                 }
             }
             .padding()
         }
     }
     
     // MARK: - 加载视图
     
     private var loadingView: some View {
         VStack(spacing: 16) {
             ProgressView()
                 .scaleEffect(1.2)
             
             Text("加载 SF Symbols...")
                 .font(.headline)
                 .foregroundColor(.secondary)
         }
         .frame(maxWidth: .infinity, maxHeight: .infinity)
     }
     
     // MARK: - 空状态视图
     
     private var emptyStateView: some View {
         VStack(spacing: 20) {
             Image(systemName: "magnifyingglass")
                 .font(.system(size: 64))
                 .foregroundColor(.secondary)
             
             Text("未找到符号")
                 .font(.title2)
                 .fontWeight(.semibold)
             
             Text("尝试调整搜索条件或选择不同的分类")
                 .font(.body)
                 .foregroundColor(.secondary)
                 .multilineTextAlignment(.center)
         }
         .frame(maxWidth: .infinity, maxHeight: .infinity)
     }
     
     // MARK: - 方法
     
     private func loadSymbols() async {
         isLoading = true
         
         // 模拟加载 SF Symbols 数据
         // 在实际应用中，这里会从系统或预定义列表中加载符号
         symbols = SFSymbolsData.getAllSymbols()
         filteredSymbols = symbols
         
         isLoading = false
     }
     
     private func filterSymbols() {
         var filtered = symbols
         
         // 按分类筛选
         if selectedCategory != .all {
             filtered = filtered.filter { $0.category == selectedCategory }
         }
         
         // 按搜索文本筛选
         if !searchText.isEmpty {
             filtered = filtered.filter { symbol in
                 symbol.name.localizedCaseInsensitiveContains(searchText) ||
                 symbol.keywords.contains { $0.localizedCaseInsensitiveContains(searchText) }
             }
         }
         
         filteredSymbols = filtered
     }
     
     private func insertSelectedSymbol() {
         guard let symbol = selectedSymbol else { return }
         
         // 使用异步更新避免在视图更新期间发布状态变化
         Task { @MainActor in
             // 切换到编辑器标签
             appState.selectedTab = .generate
             
             // 在当前 Prompt 中插入符号引用
             let symbolReference = "SF Symbol: \(symbol)"
             if appState.currentPrompt.isEmpty {
                 appState.currentPrompt = symbolReference
             } else {
                 appState.currentPrompt += ", " + symbolReference
             }
         }
     }
}


// MARK: - SF Symbol 卡片

struct SFSymbolCard: View {
    let symbol: SFSymbolInfo
    let isSelected: Bool
    let onClick: () -> Void
    let onDoubleClick: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 8) {
            // 符号图标
            Image(systemName: symbol.name)
                .font(.system(size: 32))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.accentColor : (isHovered ? Color(.controlAccentColor).opacity(0.1) : Color.clear))
                )
            
            // 符号名称
            Text(symbol.displayName)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(isSelected ? .accentColor : .primary)
        }
        .frame(width: 80, height: 100)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onClick()
        }
        .onTapGesture(count: 2) {
            onDoubleClick()
        }
    }
}

// MARK: - SF Symbol 详情视图

struct SFSymbolDetailView: View {
    let symbolName: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 大图标显示
                VStack(spacing: 16) {
                    Image(systemName: symbolName)
                        .font(.system(size: 120))
                        .foregroundColor(.accentColor)
                    
                    Text(symbolName)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                // 不同尺寸预览
                VStack(alignment: .leading, spacing: 12) {
                    Text("尺寸预览")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        ForEach([16, 24, 32, 48], id: \.self) { size in
                            VStack(spacing: 4) {
                                Image(systemName: symbolName)
                                    .font(.system(size: CGFloat(size)))
                                
                                Text("\(size)pt")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // 使用建议
                VStack(alignment: .leading, spacing: 8) {
                    Text("使用建议")
                        .font(.headline)
                    
                    Text("在 Prompt 中使用此符号可以帮助 AI 更好地理解图标的设计意图和风格方向。")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 操作按钮
                HStack(spacing: 12) {
                    Button("复制符号名") {
                        NSPasteboard.general.setString(symbolName, forType: .string)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("插入到编辑器") {
                        insertSymbolToEditor()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("关闭") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("符号详情")
            // .toolbar 已移除
        }
    }
    
    private func insertSymbolToEditor() {
        // 使用异步更新避免在视图更新期间发布状态变化
        Task { @MainActor in
            appState.selectedTab = .generate
           
           let symbolReference = "SF Symbol: \(symbolName)"
           if appState.currentPrompt.isEmpty {
                appState.currentPrompt = symbolReference
            } else {
                appState.currentPrompt += ", " + symbolReference
            }
        }
    }
}

// MARK: - 数据模型

/// SF Symbol 信息
struct SFSymbolInfo {
    let name: String
    let displayName: String
    let category: SFSymbolCategory
    let keywords: [String]
    let availability: String
    
    init(name: String, category: SFSymbolCategory, keywords: [String] = [], availability: String = "iOS 13.0+") {
        self.name = name
        self.displayName = name.replacingOccurrences(of: ".", with: " ").capitalized
        self.category = category
        self.keywords = keywords
        self.availability = availability
    }
}

/// SF Symbol 分类
enum SFSymbolCategory: String, CaseIterable, Codable {
    case all = "all"
    case communication = "communication"
    case weather = "weather"
    case objects = "objects"
    case devices = "devices"
    case connectivity = "connectivity"
    case transportation = "transportation"
    case human = "human"
    case nature = "nature"
    case editing = "editing"
    case textFormatting = "text.formatting"
    case media = "media"
    case keyboard = "keyboard"
    case commerce = "commerce"
    case time = "time"
    case health = "health"
    case gaming = "gaming"
    case shapes = "shapes"
    case arrows = "arrows"
    case indices = "indices"
    
    var displayName: String {
        switch self {
        case .all: return "全部"
        case .communication: return "通讯"
        case .weather: return "天气"
        case .objects: return "物品"
        case .devices: return "设备"
        case .connectivity: return "连接"
        case .transportation: return "交通"
        case .human: return "人物"
        case .nature: return "自然"
        case .editing: return "编辑"
        case .textFormatting: return "文本"
        case .media: return "媒体"
        case .keyboard: return "键盘"
        case .commerce: return "商务"
        case .time: return "时间"
        case .health: return "健康"
        case .gaming: return "游戏"
        case .shapes: return "形状"
        case .arrows: return "箭头"
        case .indices: return "指示"
        }
    }
}

// MARK: - 预览

#Preview {
    SFSymbolsView()
        .environmentObject(AppState.shared)
}


// macOS 13 兼容性：SwiftUI 在 macOS 14 新增 onChange(of:initial:_:)
// 这里提供一个兼容扩展，自动选择可用的重载，避免可用性编译错误。
// 删除以下私有兼容扩展，使用全局 Utilities/View+Compat.swift 中的实现
// private extension View {
//     @ViewBuilder
//     func onChangeCompat<T: Equatable>(of value: T, perform action: @escaping (T) -> Void) -> some View {
//         if #available(macOS 14.0, *) {
//             self.onChange(of: value, initial: false) { _, newValue in
//                 action(newValue)
//             }
//         } else {
//             self.onChange(of: value, perform: action)
//         }
//     }
// }