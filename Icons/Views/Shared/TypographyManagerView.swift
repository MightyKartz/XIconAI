//
//  TypographyManagerView.swift
//  Icons
//
//  Created by Icons Team
//

import SwiftUI

/// 字体层级按钮
struct TypographyLevelButton: View {
    let level: TypographyLevel
    let isSelected: Bool
    let fontSize: FontSize
    let fontWeight: FontWeight
    let action: () -> Void

    @EnvironmentObject private var themeService: ThemeService

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(level.previewText)
                    .font(level.getFont(size: fontSize))
                    .fontWeight(level.getFontWeight(weight: fontWeight))
                    .foregroundColor(isSelected ? themeService.getCurrentAccentColor() : .primary)
                    .lineLimit(1)

                Text(level.displayName)
                    .font(.caption2)
                    .foregroundColor(isSelected ? themeService.getCurrentAccentColor() : .secondary)
            }
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? themeService.getCurrentAccentColor().opacity(0.1) : Color(NSColor.controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? themeService.getCurrentAccentColor() : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .hoverEffect(style: .normal)
    }
}

/// 字体粗细标签
struct FontWeightChip: View {
    let weight: FontWeight
    let isSelected: Bool
    let action: () -> Void

    @EnvironmentObject private var themeService: ThemeService

    var body: some View {
        Button(action: action) {
            Text(weight.displayName)
                .font(.caption)
                .fontWeight(weight.titleWeight)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? themeService.getCurrentAccentColor().opacity(0.2) : Color(NSColor.controlBackgroundColor))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? themeService.getCurrentAccentColor() : Color.secondary.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .hoverEffect(style: .subtle)
    }
}

/// 字体样式管理视图 - 管理应用字体层级
struct TypographyManagerView: View {
    @EnvironmentObject private var interactionService: InteractionService
    @EnvironmentObject private var themeService: ThemeService
    @State private var selectedFontSize: FontSize = .normal
    @State private var selectedFontWeight: FontWeight = .regular
    @State private var isPreviewExpanded: Bool = true
    @State private var selectedTypographyLevel: TypographyLevel = .body

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 标题区域
            HStack {
                Image(systemName: "textformat.alt")
                    .font(.title2)
                    .foregroundColor(themeService.getCurrentAccentColor())

                Text("字体层级管理")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: {
                    withAnimation(interactionService.scaleAnimation()) {
                        isPreviewExpanded.toggle()
                    }
                }) {
                    Image(systemName: isPreviewExpanded ? "eye.slash" : "eye")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help(isPreviewExpanded ? "隐藏预览" : "显示预览")
            }
            .padding(.horizontal)

            // 字体层级选择
            VStack(alignment: .leading, spacing: 12) {
                Text("字体层级")
                    .font(.headline)
                    .fontWeight(.semibold)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(TypographyLevel.allCases) { level in
                            TypographyLevelButton(
                                level: level,
                                isSelected: selectedTypographyLevel == level,
                                fontSize: selectedFontSize,
                                fontWeight: selectedFontWeight
                            ) {
                                withAnimation(interactionService.slideAnimation()) {
                                    selectedTypographyLevel = level
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal, -16)
            }
            .padding(.horizontal)

            // 字体大小调整
            VStack(alignment: .leading, spacing: 12) {
                Text("字体大小")
                    .font(.headline)
                    .fontWeight(.semibold)

                HStack {
                    Button(action: {
                        withAnimation(interactionService.buttonPressAnimation()) {
                            decreaseFontSize()
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.title3)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedFontSize == .small)

                    Slider(
                        value: Binding(
                            get: { CGFloat(selectedFontSize.rawValue) },
                            set: { newValue in
                                let size = FontSize(rawValue: Int(newValue)) ?? .normal
                                if selectedFontSize != size {
                                    withAnimation(interactionService.slideAnimation()) {
                                        selectedFontSize = size
                                    }
                                }
                            }
                        ),
                        in: 0...3,
                        step: 1
                    )
                    .accentColor(themeService.getCurrentAccentColor())

                    Button(action: {
                        withAnimation(interactionService.buttonPressAnimation()) {
                            increaseFontSize()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedFontSize == .extraLarge)
                }

                HStack {
                    Text("小")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedFontSize.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(themeService.getCurrentAccentColor())
                    Spacer()
                    Text("大")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            // 字体粗细调整
            VStack(alignment: .leading, spacing: 12) {
                Text("字体粗细")
                    .font(.headline)
                    .fontWeight(.semibold)

                HStack(spacing: 12) {
                    ForEach(FontWeight.allCases) { weight in
                        FontWeightChip(
                            weight: weight,
                            isSelected: selectedFontWeight == weight
                        ) {
                            withAnimation(interactionService.buttonPressAnimation()) {
                                selectedFontWeight = weight
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)

            // 字体预览
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("实时预览")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

                    Button(action: {
                        withAnimation(interactionService.scaleAnimation()) {
                            resetToDefault()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("重置")
                        }
                        .font(.caption)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.secondary)
                }

                if isPreviewExpanded {
                    Divider()

                    VStack(alignment: .leading, spacing: 20) {
                        // 标题预览
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标题")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            Text("应用标题文本")
                                .font(selectedFontSize.titleFont)
                                .fontWeight(selectedFontWeight.titleWeight)
                                .foregroundColor(getTextColor())
                                .transition(.opacity.combined(with: .scale))
                        }

                        // 正文预览
                        VStack(alignment: .leading, spacing: 8) {
                            Text("正文")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            Text("这是一段正文文本，用于展示字体层级的效果。您可以调整字体大小和粗细来预览不同的视觉效果。")
                                .font(selectedFontSize.bodyFont)
                                .fontWeight(selectedFontWeight.bodyWeight)
                                .foregroundColor(getTextColor())
                                .lineSpacing(4)
                                .transition(.opacity.combined(with: .scale))
                        }

                        // 辅助文本预览
                        VStack(alignment: .leading, spacing: 8) {
                            Text("辅助信息")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            Text("这是辅助说明文本，通常用于注释或次要信息的显示。")
                                .font(selectedFontSize.captionFont)
                                .fontWeight(selectedFontWeight.captionWeight)
                                .foregroundColor(getSecondaryTextColor())
                                .transition(.opacity.combined(with: .scale))
                        }

                        // 标签文本预览
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标签")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)

                            Text("标签文本")
                                .font(selectedFontSize.labelFont)
                                .fontWeight(selectedFontWeight.labelWeight)
                                .foregroundColor(getSecondaryTextColor())
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding()
                    .themedCard()
                    .transition(.slide)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .themedBackground()
        .onAppear {
            loadTypographySettings()
        }
    }

    // MARK: - Helper Methods

    private func increaseFontSize() {
        guard let currentIndex = FontSize.allCases.firstIndex(of: selectedFontSize),
              currentIndex < FontSize.allCases.count - 1 else { return }
        selectedFontSize = FontSize.allCases[currentIndex + 1]
        saveTypographySettings()
    }

    private func decreaseFontSize() {
        guard let currentIndex = FontSize.allCases.firstIndex(of: selectedFontSize),
              currentIndex > 0 else { return }
        selectedFontSize = FontSize.allCases[currentIndex - 1]
        saveTypographySettings()
    }

    private func resetToDefault() {
        withAnimation(interactionService.bounceAnimation()) {
            selectedFontSize = .normal
            selectedFontWeight = .regular
            saveTypographySettings()
        }
    }

    private func getTextColor() -> Color {
        switch themeService.currentTheme {
        case .dark:
            return .white
        case .light, .system:
            return .black
        }
    }

    private func getSecondaryTextColor() -> Color {
        switch themeService.currentTheme {
        case .dark:
            return .gray
        case .light, .system:
            return .secondary
        }
    }

    private func saveTypographySettings() {
        UserDefaults.standard.set(selectedFontSize.rawValue, forKey: "typography_font_size")
        UserDefaults.standard.set(selectedFontWeight.rawValue, forKey: "typography_font_weight")
    }

    private func loadTypographySettings() {
        if let fontSizeRawValue = UserDefaults.standard.object(forKey: "typography_font_size") as? Int,
           let fontSize = FontSize(rawValue: fontSizeRawValue) {
            selectedFontSize = fontSize
        }

        if let fontWeightRawValue = UserDefaults.standard.object(forKey: "typography_font_weight") as? String,
           let fontWeight = FontWeight(rawValue: fontWeightRawValue) {
            selectedFontWeight = fontWeight
        }
    }
}

/// ThemedText 视图 - 根据主题自动调整文本颜色
struct ThemedText: View {
    let text: String
    let textStyle: TextStyle
    let alignment: TextAlignment

    @EnvironmentObject private var themeService: ThemeService

    init(_ text: String, style: TextStyle, alignment: TextAlignment = .leading) {
        self.text = text
        self.textStyle = style
        self.alignment = alignment
    }

    var body: some View {
        Text(text)
            .font(textStyle.font)
            .fontWeight(textStyle.weight)
            .foregroundColor(textStyle.color)
            .multilineTextAlignment(alignment.toSwiftUI)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - 字体大小枚举
enum FontSize: Int, CaseIterable, Identifiable {
    case small = 0
    case normal = 1
    case large = 2
    case extraLarge = 3

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .small: return "小"
        case .normal: return "标准"
        case .large: return "大"
        case .extraLarge: return "超大"
        }
    }

    var titleFont: Font {
        switch self {
        case .small: return .title3
        case .normal: return .title2
        case .large: return .title
        case .extraLarge: return .largeTitle
        }
    }

    var bodyFont: Font {
        switch self {
        case .small: return .callout
        case .normal: return .body
        case .large: return .body
        case .extraLarge: return .body
        }
    }

    var captionFont: Font {
        switch self {
        case .small: return .caption
        case .normal: return .caption
        case .large: return .caption
        case .extraLarge: return .caption
        }
    }

    var labelFont: Font {
        switch self {
        case .small: return .caption2
        case .normal: return .caption
        case .large: return .caption
        case .extraLarge: return .caption
        }
    }
}

// MARK: - 字体粗细枚举
enum FontWeight: String, CaseIterable, Identifiable {
    case light = "light"
    case regular = "regular"
    case medium = "medium"
    case bold = "bold"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light: return "细"
        case .regular: return "标准"
        case .medium: return "中等"
        case .bold: return "粗"
        }
    }

    var titleWeight: Font.Weight {
        switch self {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .bold: return .bold
        }
    }

    var bodyWeight: Font.Weight {
        switch self {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .bold: return .semibold
        }
    }

    var captionWeight: Font.Weight {
        switch self {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .bold: return .semibold
        }
    }

    var labelWeight: Font.Weight {
        switch self {
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .bold: return .semibold
        }
    }
}

// MARK: - 字体层级枚举
enum TypographyLevel: String, CaseIterable, Identifiable {
    case display
    case title
    case subtitle
    case body
    case caption
    case label

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .display: return "展示"
        case .title: return "标题"
        case .subtitle: return "副标题"
        case .body: return "正文"
        case .caption: return "辅助"
        case .label: return "标签"
        }
    }

    var previewText: String {
        switch self {
        case .display: return "Aa"
        case .title: return "标题"
        case .subtitle: return "副标题"
        case .body: return "正文"
        case .caption: return "辅助"
        case .label: return "标签"
        }
    }

    func getFont(size: FontSize) -> Font {
        switch self {
        case .display:
            return size.titleFont
        case .title:
            return size.titleFont
        case .subtitle:
            switch size {
            case .small: return .title3
            case .normal: return .title2
            case .large: return .title
            case .extraLarge: return .largeTitle
            }
        case .body:
            return size.bodyFont
        case .caption:
            return size.captionFont
        case .label:
            return size.labelFont
        }
    }

    func getFontWeight(weight: FontWeight) -> Font.Weight {
        switch self {
        case .display:
            return weight.titleWeight
        case .title:
            return weight.titleWeight
        case .subtitle:
            return weight.titleWeight
        case .body:
            return weight.bodyWeight
        case .caption:
            return weight.captionWeight
        case .label:
            return weight.labelWeight
        }
    }
}

// MARK: - 文本样式
struct TextStyle {
    let font: Font
    let weight: Font.Weight
    let color: Color

    static let title = TextStyle(font: .title2, weight: .bold, color: .primary)
    static let subtitle = TextStyle(font: .title3, weight: .semibold, color: .primary)
    static let body = TextStyle(font: .body, weight: .regular, color: .primary)
    static let caption = TextStyle(font: .caption, weight: .regular, color: .secondary)
    static let label = TextStyle(font: .caption2, weight: .medium, color: .secondary)
}

// MARK: - 文本对齐枚举
enum TextAlignment {
    case leading, center, trailing

    var toSwiftUI: SwiftUI.TextAlignment {
        switch self {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        Text("字体层级管理组件")
            .font(.title2)
            .fontWeight(.bold)

        // 字体管理器预览
        TypographyManagerView()
            .environmentObject(InteractionService.shared)
            .environmentObject(ThemeService.shared)
            .frame(height: 400)

        // 字体层级按钮预览
        VStack(alignment: .leading, spacing: 12) {
            Text("字体层级按钮")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(TypographyLevel.allCases) { level in
                    TypographyLevelButton(
                        level: level,
                        isSelected: level == .body,
                        fontSize: .normal,
                        fontWeight: .regular,
                        action: {}
                    )
                }
            }
            .environmentObject(ThemeService.shared)
        }

        // 字体粗细标签预览
        VStack(alignment: .leading, spacing: 12) {
            Text("字体粗细标签")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(FontWeight.allCases) { weight in
                    FontWeightChip(
                        weight: weight,
                        isSelected: weight == .regular,
                        action: {}
                    )
                }
            }
            .environmentObject(ThemeService.shared)
        }

        // 主题文本预览
        VStack(alignment: .leading, spacing: 12) {
            Text("主题文本样式")
                .font(.headline)

            ThemedText("标题文本", style: .title)
            ThemedText("子标题文本", style: .subtitle)
            ThemedText("正文文本内容，用于展示字体效果。", style: .body)
            ThemedText("辅助说明文本", style: .caption)
            ThemedText("标签文本", style: .label)
        }
        .environmentObject(ThemeService.shared)
    }
    .frame(width: 400, height: 600)
    .padding()
    .background(Color(NSColor.windowBackgroundColor))
}