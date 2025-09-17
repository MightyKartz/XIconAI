import SwiftUI

// Environment key for Liquid Glass effect
struct LiquidGlassEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var liquidGlassEffect: Bool {
        get { self[LiquidGlassEnvironmentKey.self] }
        set { self[LiquidGlassEnvironmentKey.self] = newValue }
    }
}

/// Native SwiftUI button styles aligned with macOS 26 design guidelines
struct PrimaryButtonStyle: SwiftUI.ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controlSize) var controlSize
    @Environment(\.liquidGlassEffect) var liquidGlassEffect
    @Environment(\.layoutService) var layoutService

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundView(configuration: configuration))
            .foregroundColor(foregroundColor(configuration: configuration))
            .font(.body.weight(.medium))
            .cornerRadius(cornerRadius)
    }

    private var horizontalPadding: CGFloat {
        switch controlSize {
        case .mini:
            return 12
        case .small:
            return 16
        case .large:
            return 24
        case .regular:
            fallthrough
        default:
            return 20
        }
    }

    private var verticalPadding: CGFloat {
        switch controlSize {
        case .mini:
            return 4
        case .small:
            return 6
        case .large:
            return 14
        case .regular:
            fallthrough
        default:
            return 10
        }
    }

    private var cornerRadius: CGFloat {
        switch controlSize {
        case .mini:
            return 4
        case .small:
            return 6
        case .large:
            return 10
        case .regular:
            fallthrough
        default:
            return 8
        }
    }

    private func backgroundView(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        Group {
            if liquidGlassEffect {
                // Liquid Glass effect for primary button
                ZStack {
                    // Blur background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.clear)
                        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
                        .opacity(colorScheme == .dark ? 0.8 : 0.7)

                    // Gradient overlay with adjusted opacity for dark mode
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.accentColor.opacity(colorScheme == .dark ? 0.9 : 0.9),
                                    Color.accentColor.opacity(colorScheme == .dark ? 0.8 : 0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(configuration.isPressed ? 0.9 : 1.0)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            colorScheme == .dark ?
                                Color.white.opacity(0.25) :
                                Color.white.opacity(0.3),
                            lineWidth: 1
                        )
                )
            } else {
                // Standard button
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(configuration.isPressed ?
                        Color.accentColor.opacity(colorScheme == .dark ? 0.8 : 0.9) :
                        Color.accentColor)
                    .shadow(color: Color.black.opacity(0.1), radius: configuration.isPressed ? 1 : 2, x: 0, y: configuration.isPressed ? 0 : 1)
            }
        }
    }

    private func foregroundColor(configuration: SwiftUI.ButtonStyleConfiguration) -> Color {
        if liquidGlassEffect {
            // 在Liquid Glass效果下，使用适应性文本颜色以确保在所有背景上都有良好的可读性
            // 浅色模式下使用.primary，深色模式下使用.white以获得更好的对比度
            return colorScheme == .dark ? .white : .primary
        }
        return colorScheme == .dark ? .black : .white
    }
}

struct SecondaryButtonStyle: SwiftUI.ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controlSize) var controlSize
    @Environment(\.liquidGlassEffect) var liquidGlassEffect
    @Environment(\.layoutService) var layoutService

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundView(configuration: configuration))
            .foregroundColor(foregroundColor(configuration: configuration))
            .font(.body.weight(.medium))
            .cornerRadius(cornerRadius)
    }

    private var horizontalPadding: CGFloat {
        switch controlSize {
        case .mini:
            return 12
        case .small:
            return 16
        case .large:
            return 24
        case .regular:
            fallthrough
        default:
            return 20
        }
    }

    private var verticalPadding: CGFloat {
        switch controlSize {
        case .mini:
            return 4
        case .small:
            return 6
        case .large:
            return 14
        case .regular:
            fallthrough
        default:
            return 10
        }
    }

    private var cornerRadius: CGFloat {
        switch controlSize {
        case .mini:
            return 4
        case .small:
            return 6
        case .large:
            return 10
        case .regular:
            fallthrough
        default:
            return 8
        }
    }

    private func backgroundView(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        Group {
            if liquidGlassEffect {
                // Liquid Glass effect for secondary button
                ZStack {
                    // Blur background
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.clear)
                        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
                        .opacity(colorScheme == .dark ? 0.6 : 0.5)

                    // Gradient overlay with enhanced visibility in dark mode
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    colorScheme == .dark ?
                                        Color.gray.opacity(0.4) :
                                        Color.gray.opacity(0.2),
                                    colorScheme == .dark ?
                                        Color.gray.opacity(0.3) :
                                        Color.gray.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(configuration.isPressed ? 0.8 : 1.0)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            colorScheme == .dark ?
                                Color.white.opacity(0.2) :
                                Color.black.opacity(0.1),
                            lineWidth: 1
                        )
                )
            } else {
                // Standard button
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(configuration.isPressed ?
                        Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2) :
                        Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.1))
            }
        }
    }

    private func foregroundColor(configuration: SwiftUI.ButtonStyleConfiguration) -> Color {
        if liquidGlassEffect {
            // 在Liquid Glass效果下，使用适应性强调色以确保在所有背景上都有良好的可读性
            let accentColor = Color.accentColor
            if configuration.isPressed {
                return colorScheme == .dark ?
                    accentColor.opacity(0.95) :
                    accentColor.opacity(0.9)
            } else {
                // 非按下状态使用更高的不透明度以确保可读性
                return colorScheme == .dark ?
                    accentColor.opacity(0.98) :
                    accentColor
            }
        }
        return configuration.isPressed ?
            Color.accentColor.opacity(colorScheme == .dark ? 0.8 : 0.7) :
            Color.accentColor
    }
}

struct DestructiveButtonStyle: SwiftUI.ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controlSize) var controlSize

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundView(configuration: configuration))
            .foregroundColor(foregroundColor(configuration: configuration))
            .font(.body.weight(.medium))
            .cornerRadius(cornerRadius)
    }

    private var horizontalPadding: CGFloat {
        switch controlSize {
        case .mini:
            return 12
        case .small:
            return 16
        case .large:
            return 24
        case .regular:
            fallthrough
        default:
            return 20
        }
    }

    private var verticalPadding: CGFloat {
        switch controlSize {
        case .mini:
            return 4
        case .small:
            return 6
        case .large:
            return 14
        case .regular:
            fallthrough
        default:
            return 10
        }
    }

    private var cornerRadius: CGFloat {
        switch controlSize {
        case .mini:
            return 4
        case .small:
            return 6
        case .large:
            return 10
        case .regular:
            fallthrough
        default:
            return 8
        }
    }

    private func backgroundView(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(configuration.isPressed ?
                Color.red.opacity(colorScheme == .dark ? 0.8 : 0.9) :
                Color.red)
            .shadow(color: Color.black.opacity(0.1), radius: configuration.isPressed ? 1 : 2, x: 0, y: configuration.isPressed ? 0 : 1)
    }

    private func foregroundColor(configuration: SwiftUI.ButtonStyleConfiguration) -> Color {
        return colorScheme == .dark ? .black : .white
    }
}

struct OutlineButtonStyle: SwiftUI.ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controlSize) var controlSize

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundView(configuration: configuration))
            .foregroundColor(foregroundColor(configuration: configuration))
            .font(.body.weight(.medium))
            .cornerRadius(cornerRadius)
    }

    private var horizontalPadding: CGFloat {
        switch controlSize {
        case .mini:
            return 12
        case .small:
            return 16
        case .large:
            return 24
        case .regular:
            fallthrough
        default:
            return 20
        }
    }

    private var verticalPadding: CGFloat {
        switch controlSize {
        case .mini:
            return 4
        case .small:
            return 6
        case .large:
            return 14
        case .regular:
            fallthrough
        default:
            return 10
        }
    }

    private var cornerRadius: CGFloat {
        switch controlSize {
        case .mini:
            return 4
        case .small:
            return 6
        case .large:
            return 10
        case .regular:
            fallthrough
        default:
            return 8
        }
    }

    private func backgroundView(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        Group {
            if liquidGlassEffect {
                // Liquid Glass effect for outline button
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.clear)
                        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
                        .opacity(colorScheme == .dark ? 0.4 : 0.3)

                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(configuration.isPressed ?
                            Color.accentColor.opacity(colorScheme == .dark ? 0.8 : 0.7) :
                            Color.primary.opacity(colorScheme == .dark ? 0.6 : 0.4),
                            lineWidth: 1)
                }
            } else {
                // Standard outline button
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(configuration.isPressed ?
                                Color.accentColor.opacity(0.7) :
                                Color.primary.opacity(colorScheme == .dark ? 0.5 : 0.3),
                                lineWidth: 1)
                    )
            }
        }
    }

    private func foregroundColor(configuration: SwiftUI.ButtonStyleConfiguration) -> Color {
        if liquidGlassEffect {
            // 在Liquid Glass效果下，使用适应性强调色以确保在所有背景上都有良好的可读性
            let accentColor = Color.accentColor
            if configuration.isPressed {
                return colorScheme == .dark ?
                    accentColor.opacity(0.9) :
                    accentColor.opacity(0.85)
            } else {
                // 非按下状态使用更高的不透明度以确保可读性
                return colorScheme == .dark ?
                    accentColor.opacity(0.95) :
                    accentColor.opacity(0.9)
            }
        } else {
            return configuration.isPressed ?
                Color.accentColor.opacity(colorScheme == .dark ? 0.8 : 0.7) :
                Color.accentColor
        }
    }
}

struct GhostButtonStyle: SwiftUI.ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.controlSize) var controlSize

    func makeBody(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        configuration.label
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(backgroundView(configuration: configuration))
            .foregroundColor(foregroundColor(configuration: configuration))
            .font(.body.weight(.medium))
            .cornerRadius(cornerRadius)
    }

    private var horizontalPadding: CGFloat {
        switch controlSize {
        case .mini:
            return 12
        case .small:
            return 16
        case .large:
            return 24
        case .regular:
            fallthrough
        default:
            return 20
        }
    }

    private var verticalPadding: CGFloat {
        switch controlSize {
        case .mini:
            return 4
        case .small:
            return 6
        case .large:
            return 14
        case .regular:
            fallthrough
        default:
            return 10
        }
    }

    private var cornerRadius: CGFloat {
        switch controlSize {
        case .mini:
            return 4
        case .small:
            return 6
        case .large:
            return 10
        case .regular:
            fallthrough
        default:
            return 8
        }
    }

    private func backgroundView(configuration: SwiftUI.ButtonStyleConfiguration) -> some View {
        Group {
            if liquidGlassEffect {
                // Liquid Glass effect for ghost button
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.clear)
                        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
                        .opacity(colorScheme == .dark ? 0.3 : 0.2)

                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(configuration.isPressed ?
                            Color.accentColor.opacity(colorScheme == .dark ? 0.3 : 0.2) :
                            Color.clear)
                }
            } else {
                // Standard ghost button
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(configuration.isPressed ?
                        Color.accentColor.opacity(colorScheme == .dark ? 0.2 : 0.1) :
                        Color.clear)
            }
        }
    }

    private func foregroundColor(configuration: SwiftUI.ButtonStyleConfiguration) -> Color {
        if liquidGlassEffect {
            // 在Liquid Glass效果下，使用适应性强调色以确保在所有背景上都有良好的可读性
            let accentColor = Color.accentColor
            if configuration.isPressed {
                return colorScheme == .dark ?
                    accentColor.opacity(0.9) :
                    accentColor.opacity(0.85)
            } else {
                // 非按下状态使用更高的不透明度以确保可读性
                return colorScheme == .dark ?
                    accentColor.opacity(0.95) :
                    accentColor.opacity(0.9)
            }
        } else {
            return configuration.isPressed ?
                Color.accentColor.opacity(colorScheme == .dark ? 0.8 : 0.7) :
                Color.accentColor
        }
    }
}

// MARK: - Visual Effect View for Liquid Glass
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// Extension to make it easier to apply button styles
extension Button {
    func primaryStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }

    func secondaryStyle() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }

    func destructiveStyle() -> some View {
        self.buttonStyle(DestructiveButtonStyle())
    }

    func outlineStyle() -> some View {
        self.buttonStyle(OutlineButtonStyle())
    }

    func ghostStyle() -> some View {
        self.buttonStyle(GhostButtonStyle())
    }
}