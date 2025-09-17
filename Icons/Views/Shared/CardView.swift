import SwiftUI

/// Native SwiftUI card component aligned with macOS 26 design guidelines
/// Uses standard GroupBox with proper material design and system colors
struct CardView<Content: View>: View {
    var title: String?
    var description: String?
    var footer: String?
    var content: Content
    var useLiquidGlass: Bool = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeService) var themeService
    @Environment(\.layoutService) var layoutService

    init(
        title: String? = nil,
        description: String? = nil,
        footer: String? = nil,
        useLiquidGlass: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.footer = footer
        self.useLiquidGlass = useLiquidGlass
        self.content = content()
    }

    var shouldUseLiquidGlass: Bool {
        // 如果明确指定使用Liquid Glass，则使用
        // 否则根据LayoutService设置和当前主题决定
        if useLiquidGlass {
            return true
        }

        // 在启用Liquid Glass效果时，无论浅色还是深色模式都使用
        return layoutService.enableLiquidGlassEffect
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                // Title and description section
                if title != nil || description != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        if let title = title {
                            Text(title)
                                .font(.title2)
                                .fontWeight(.semibold)  // 增强标题字体重量以提高可读性
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if let description = description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                // Main content
                content
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Footer
                if let footer = footer {
                    Text(footer)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityHint("卡片页脚信息")  // 添加辅助功能提示
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .groupBoxStyle(AnyGroupBoxStyle(shouldUseLiquidGlass))
    }
}

/// Custom GroupBox style for cards using native macOS materials
struct CardGroupBoxStyle: GroupBoxStyle {
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label (if provided)
            configuration.label
                .font(.headline)
                .foregroundStyle(.primary)

            // Content with proper styling
            configuration.content
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(NSColor.controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            colorScheme == .dark ?
                                Color.white.opacity(0.1) :
                                Color.black.opacity(0.05),
                            lineWidth: 1
                        )
                )
        }
    }
}

/// Liquid Glass GroupBox style for cards with macOS 26 effect
struct LiquidGlassCardGroupBoxStyle: GroupBoxStyle {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeService) var themeService

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label (if provided)
            configuration.label
                .font(.headline)
                .foregroundStyle(.primary)

            // Content with Liquid Glass styling
            configuration.content
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    themeService.getLiquidGlassBackground()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            colorScheme == .dark ?
                                Color.white.opacity(0.25) :  // 增加深色模式下的边框不透明度
                                Color.white.opacity(0.6),   // 增加浅色模式下的边框不透明度
                            lineWidth: 1
                        )
                )
                .cornerRadius(16)
        }
    }
}

/// Extension to create cards with predefined styles
extension GroupBox {
    func cardStyle() -> some View {
        self.groupBoxStyle(CardGroupBoxStyle())
    }
}

// Preview
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CardView(
                title: "Card Title",
                description: "This is a card description",
                footer: "Card footer"
            ) {
                Text("Card content goes here")
                    .font(.body)
            }

            CardView(
                title: "Custom Content Card",
                description: "This card has custom content"
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("This is custom content inside the card.")
                        .font(.body)

                    Button("Card Button") {
                        print("Button tapped!")
                    }
                    .primaryStyle()
                }
            }

            CardView {
                Text("Simple card with no title or description")
                    .font(.body)
            }

            CardView(
                title: "Liquid Glass Card",
                description: "This card uses the new Liquid Glass effect for macOS 26",
                useLiquidGlass: true
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("This card demonstrates the Liquid Glass effect.")
                        .font(.body)

                    Button("Glass Button") {
                        print("Glass button tapped!")
                    }
                    .primaryStyle()
                }
            }
        }
        .environment(\.themeService, ThemeService.shared)
        .padding()
        .frame(width: 400)
    }
}

/// Type-erased GroupBox style wrapper
struct AnyGroupBoxStyle: GroupBoxStyle {
    private let _makeBody: (Configuration) -> AnyView

    init(_ useLiquidGlass: Bool) {
        if useLiquidGlass {
            _makeBody = { configuration in
                AnyView(LiquidGlassCardGroupBoxStyle().makeBody(configuration: configuration))
            }
        } else {
            _makeBody = { configuration in
                AnyView(CardGroupBoxStyle().makeBody(configuration: configuration))
            }
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}