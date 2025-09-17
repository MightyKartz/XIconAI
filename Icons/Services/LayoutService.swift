//
//  LayoutService.swift
//  Icons
//
//  Created by Icons App on 2024/01/15.
//

import SwiftUI
import Combine

// MARK: - Layout Service
class LayoutService: ObservableObject {
    static let shared = LayoutService()
    
    @Published var windowSize: CGSize = CGSize(width: 1200, height: 800)
    @Published var sidebarWidth: CGFloat = 250
    @Published var isCompact: Bool = false
    @Published var orientation: DeviceOrientation = .landscape
    @Published var layoutMode: LayoutMode = .comfortable
    @Published var enableLiquidGlassEffect: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let sidebarWidthKey = "sidebar_width"
    private let layoutModeKey = "layout_mode"
    private let enableLiquidGlassEffectKey = "enable_liquid_glass_effect"
    
    // Layout breakpoints
    private let compactWidthThreshold: CGFloat = 900
    private let minSidebarWidth: CGFloat = 200
    private let maxSidebarWidth: CGFloat = 400
    
    private init() {
        loadLayoutSettings()
        setupWindowSizeObserver()
    }
    
    // MARK: - Public Methods
    
    func updateWindowSize(_ size: CGSize) {
        windowSize = size
        updateLayoutMode()
        updateOrientation()
        updateCompactMode()
    }
    
    func setSidebarWidth(_ width: CGFloat) {
        // Allow 0 width for hiding sidebar, otherwise clamp to min/max
        let clampedWidth = width == 0 ? 0 : max(minSidebarWidth, min(maxSidebarWidth, width))
        sidebarWidth = clampedWidth
        saveLayoutSettings()
    }
    
    func setLayoutMode(_ mode: LayoutMode) {
        layoutMode = mode
        saveLayoutSettings()
    }
    
    func toggleSidebar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            // Always toggle between hidden and visible states
            // Use a small threshold to handle potential floating point issues
            if sidebarWidth > 1 {
                setSidebarWidth(0)
            } else {
                setSidebarWidth(250)
            }
        }
    }

    // Check if sidebar is currently visible
    var isSidebarVisible: Bool {
        layoutMode.sidebarVisible && sidebarWidth > 1
    }

    // Force reset sidebar to ensure it works after potential state issues
    func forceShowSidebar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            setSidebarWidth(250)
        }
    }

    func setLiquidGlassEffect(_ enabled: Bool) {
        enableLiquidGlassEffect = enabled
        saveLayoutSettings()
    }
    
    // MARK: - Computed Properties
    
    var contentWidth: CGFloat {
        max(0, windowSize.width - sidebarWidth)
    }
    
    var gridColumns: Int {
        let availableWidth = contentWidth - 40 // padding
        let itemWidth: CGFloat = isCompact ? 120 : 150
        return max(1, Int(availableWidth / itemWidth))
    }
    
    var cardSize: CGSize {
        let width: CGFloat = isCompact ? 120 : 150
        let height: CGFloat = isCompact ? 120 : 150
        return CGSize(width: width, height: height)
    }
    
    var spacing: CGFloat {
        isCompact ? 8 : 12
    }
    
    var padding: EdgeInsets {
        EdgeInsets(
            top: isCompact ? 8 : 16,
            leading: isCompact ? 8 : 16,
            bottom: isCompact ? 8 : 16,
            trailing: isCompact ? 8 : 16
        )
    }
    
    // MARK: - Private Methods
    
    private func setupWindowSizeObserver() {
        // Monitor window size changes
        NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let window = notification.object as? NSWindow {
                self?.updateWindowSize(window.frame.size)
            }
        }
    }
    
    private func updateLayoutMode() {
        let newMode: LayoutMode
        
        if windowSize.width < 900 {
            newMode = .compact
        } else if windowSize.width < 1200 {
            newMode = .comfortable
        } else {
            newMode = .spacious
        }
        
        if newMode != layoutMode {
            layoutMode = newMode
        }
    }
    
    private func updateOrientation() {
        let newOrientation: DeviceOrientation = windowSize.width > windowSize.height ? .landscape : .portrait
        if newOrientation != orientation {
            orientation = newOrientation
        }
    }
    
    private func updateCompactMode() {
        let newIsCompact = windowSize.width < compactWidthThreshold
        if newIsCompact != isCompact {
            isCompact = newIsCompact
            
            // Adjust sidebar width for compact mode
            if isCompact && sidebarWidth > 200 {
                setSidebarWidth(200)
            }
        }
    }
    
    private func loadLayoutSettings() {
        sidebarWidth = userDefaults.object(forKey: sidebarWidthKey) as? CGFloat ?? 250

        if let layoutModeRawValue = userDefaults.object(forKey: layoutModeKey) as? String,
           let mode = LayoutMode(rawValue: layoutModeRawValue) {
            layoutMode = mode
        }

        enableLiquidGlassEffect = userDefaults.object(forKey: enableLiquidGlassEffectKey) as? Bool ?? true
    }
    
    private func saveLayoutSettings() {
        userDefaults.set(sidebarWidth, forKey: sidebarWidthKey)
        userDefaults.set(layoutMode.rawValue, forKey: layoutModeKey)
        userDefaults.set(enableLiquidGlassEffect, forKey: enableLiquidGlassEffectKey)
    }
}

// MARK: - Layout Mode
enum LayoutMode: String, CaseIterable, Identifiable {
    case compact = "compact"
    case comfortable = "comfortable"
    case spacious = "spacious"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .compact:
            return "紧凑"
        case .comfortable:
            return "舒适"
        case .spacious:
            return "宽松"
        }
    }
    
    var description: String {
        switch self {
        case .compact:
            return "最大化内容显示"
        case .comfortable:
            return "平衡布局"
        case .spacious:
            return "更多空白空间"
        }
    }
    
    var sidebarVisible: Bool {
        switch self {
        case .compact:
            return false
        case .comfortable, .spacious:
            return true
        }
    }
    
    var toolbarStyle: ToolbarStyle {
        switch self {
        case .compact:
            return .compact
        case .comfortable, .spacious:
            return .standard
        }
    }
}

// MARK: - Device Orientation
enum DeviceOrientation: String, CaseIterable {
    case portrait = "portrait"
    case landscape = "landscape"
    
    var displayName: String {
        switch self {
        case .portrait:
            return "竖屏"
        case .landscape:
            return "横屏"
        }
    }
}

// MARK: - Toolbar Style
enum ToolbarStyle {
    case compact
    case standard
    
    var height: CGFloat {
        switch self {
        case .compact:
            return 40
        case .standard:
            return 52
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .compact:
            return 16
        case .standard:
            return 20
        }
    }
}

// MARK: - Responsive Grid
struct ResponsiveGrid<Content: View>: View {
    @EnvironmentObject private var layoutService: LayoutService
    
    let content: () -> Content
    let minItemWidth: CGFloat
    let spacing: CGFloat
    
    init(
        minItemWidth: CGFloat = 150,
        spacing: CGFloat = 12,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.minItemWidth = minItemWidth
        self.spacing = spacing
        self.content = content
    }
    
    private var columns: [GridItem] {
        let availableWidth = layoutService.contentWidth - (layoutService.padding.leading + layoutService.padding.trailing)
        let columnCount = max(1, Int(availableWidth / (minItemWidth + spacing)))
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            content()
        }
        .padding(layoutService.padding)
    }
}

// MARK: - Layout Environment Key
struct LayoutEnvironmentKey: EnvironmentKey {
    static let defaultValue = LayoutService.shared
}

extension EnvironmentValues {
    var layoutService: LayoutService {
        get { self[LayoutEnvironmentKey.self] }
        set { self[LayoutEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Extensions
extension View {
    func responsiveFrame(minWidth: CGFloat = 0, maxWidth: CGFloat = .infinity) -> some View {
        self.frame(minWidth: minWidth, maxWidth: maxWidth)
    }
    
    func adaptiveFont(_ style: Font.TextStyle) -> some View {
        self.font(.system(style, design: .default))
    }
    
    func responsivePadding() -> some View {
        self.modifier(ResponsivePaddingModifier())
    }
}

// MARK: - Responsive Padding Modifier
struct ResponsivePaddingModifier: ViewModifier {
    @EnvironmentObject private var layoutService: LayoutService
    
    func body(content: Content) -> some View {
        content.padding(layoutService.padding)
    }
}