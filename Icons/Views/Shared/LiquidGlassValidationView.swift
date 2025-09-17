import SwiftUI

/// 验证Liquid Glass效果的文本可读性和视觉效果
struct LiquidGlassValidationView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeService) var themeService
    @Environment(\.layoutService) var layoutService

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 标题部分
                VStack(alignment: .leading, spacing: 8) {
                    Text("Liquid Glass 效果验证")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("确保文本可读性和视觉效果符合 macOS 26 设计规范")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)

                // 设置说明
                CardView(
                    title: "验证说明",
                    description: "此视图用于验证 Liquid Glass 效果的文本可读性和整体视觉表现"
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("验证内容包括:")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("• 文本在不同背景下的可读性")
                            Text("• 按钮在 Liquid Glass 背景上的对比度")
                            Text("• 卡片组件的视觉层次感")
                            Text("• 整体界面的视觉一致性")
                        }
                        .font(.body)

                        HStack {
                            Text("当前设置:")
                                .font(.headline)
                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Liquid Glass 效果:")
                                Spacer()
                                Text(layoutService.enableLiquidGlassEffect ? "启用" : "禁用")
                                    .foregroundColor(layoutService.enableLiquidGlassEffect ? .green : .red)
                            }

                            HStack {
                                Text("当前主题:")
                                Spacer()
                                Text(themeService.currentTheme.displayName)
                            }

                            HStack {
                                Text("颜色方案:")
                                Spacer()
                                Text(colorScheme == .dark ? "深色" : "浅色")
                            }
                        }
                        .font(.subheadline)
                    }
                }

                // 文本可读性测试
                CardView(
                    title: "文本可读性测试",
                    description: "验证在 Liquid Glass 背景上的文本可读性"
                ) {
                    VStack(alignment: .leading, spacing: 15) {
                        Group {
                            Text("主要文本 - 高对比度")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            Text("常规文本 - 标准对比度")
                                .font(.body)
                                .foregroundStyle(.primary)

                            Text("次要文本 - 中等对比度")
                                .font(.body)
                                .foregroundStyle(.secondary)

                            Text("辅助文本 - 低对比度")
                                .font(.caption)
                                .foregroundStyle(.tertiary)

                            Text("强调文本 - 可交互元素")
                                .font(.body)
                                .foregroundStyle(Color.accentColor)

                            Text("禁用文本 - 不可交互元素")
                                .font(.body)
                                .foregroundStyle(.disabled)
                                .accessibilityLabel("禁用文本不可交互元素示例")
                        }

                        // 增加不同字体大小的文本可读性测试
                        Group {
                            Text("超大标题文本")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .accessibilityLabel("超大标题文本示例")

                            Text("小号文本")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("小号文本示例")
                        }

                        Divider()

                        // 文本对比度测试
                        VStack(alignment: .leading, spacing: 10) {
                            Text("文本对比度测试:")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)

                            Text("此部分测试不同颜色文本在 Liquid Glass 背景上的可读性。所有文本应清晰可读且无眩光。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        // 不同颜色文本测试
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3), spacing: 15) {
                            ForEach(["红", "绿", "蓝", "黄", "紫", "橙"], id: \.self) { color in
                                Text("\(color)色文本")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(getColor(for: color))
                                            .opacity(0.8)
                                    )
                                    .foregroundColor(getContrastColor(for: color))
                                    .accessibilityLabel("\(color)色文本示例")
                            }
                        }
                    }
                }
                .groupBoxStyle(layoutService.enableLiquidGlassEffect ? LiquidGlassCardGroupBoxStyle() : CardGroupBoxStyle())

                // 按钮样式对比
                CardView(
                    title: "按钮样式对比",
                    description: "比较不同按钮样式在 Liquid Glass 背景上的表现"
                ) {
                    VStack(spacing: 15) {
                        // 主要按钮
                        VStack(alignment: .leading, spacing: 8) {
                            Text("主要按钮")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            HStack(spacing: 15) {
                                Button("标准按钮") {}
                                    .primaryStyle()
                                    .environment(\.liquidGlassEffect, false)

                                Button("Liquid Glass 按钮") {}
                                    .primaryStyle()
                                    .environment(\.liquidGlassEffect, true)
                            }
                        }

                        Divider()

                        // 次要按钮
                        VStack(alignment: .leading, spacing: 8) {
                            Text("次要按钮")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            HStack(spacing: 15) {
                                Button("标准按钮") {}
                                    .secondaryStyle()
                                    .environment(\.liquidGlassEffect, false)

                                Button("Liquid Glass 按钮") {}
                                    .secondaryStyle()
                                    .environment(\.liquidGlassEffect, true)
                            }
                        }

                        Divider()

                        // 轮廓按钮
                        VStack(alignment: .leading, spacing: 8) {
                            Text("轮廓按钮")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            HStack(spacing: 15) {
                                Button("标准按钮") {}
                                    .outlineStyle()
                                    .environment(\.liquidGlassEffect, false)

                                Button("Liquid Glass 按钮") {}
                                    .outlineStyle()
                                    .environment(\.liquidGlassEffect, true)
                            }
                        }

                        Divider()

                        // 幽灵按钮
                        VStack(alignment: .leading, spacing: 8) {
                            Text("幽灵按钮")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            HStack(spacing: 15) {
                                Button("标准按钮") {}
                                    .ghostStyle()
                                    .environment(\.liquidGlassEffect, false)

                                Button("Liquid Glass 按钮") {}
                                    .ghostStyle()
                                    .environment(\.liquidGlassEffect, true)
                            }
                        }
                    }
                }
                .groupBoxStyle(layoutService.enableLiquidGlassEffect ? LiquidGlassCardGroupBoxStyle() : CardGroupBoxStyle())

                // 颜色对比度测试
                CardView(
                    title: "颜色对比度测试",
                    description: "验证不同颜色在 Liquid Glass 背景上的对比度"
                ) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("系统颜色:")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                            ForEach(0..<12) { index in
                                ColorCard(color: Color(white: Double(index) / 11.0), name: "灰度 \(index)")
                            }
                        }

                        Text("强调色:")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .padding(.top)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                            ColorCard(color: .red, name: "红色")
                            ColorCard(color: .orange, name: "橙色")
                            ColorCard(color: .yellow, name: "黄色")
                            ColorCard(color: .green, name: "绿色")
                            ColorCard(color: .blue, name: "蓝色")
                            ColorCard(color: .purple, name: "紫色")
                            ColorCard(color: .pink, name: "粉色")
                            ColorCard(color: .indigo, name: "靛蓝")
                        }
                    }
                }
                .groupBoxStyle(layoutService.enableLiquidGlassEffect ? LiquidGlassCardGroupBoxStyle() : CardGroupBoxStyle())

                // 控件测试
                CardView(
                    title: "控件测试",
                    description: "验证各种控件在 Liquid Glass 背景上的表现",
                    useLiquidGlass: true
                ) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("切换开关:")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        HStack {
                            Toggle("选项 1", isOn: .constant(true))
                            Spacer()
                            Toggle("选项 2", isOn: .constant(false))
                        }

                        Divider()

                        Text("滑块:")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Slider(value: .constant(0.5), in: 0...1)

                        Divider()

                        Text("进度条:")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        ProgressView(value: 0.7)
                            .progressViewStyle(LinearProgressViewStyle())

                        Divider()

                        Text("选择器:")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Picker("选择选项", selection: .constant(1)) {
                            Text("选项 1").tag(1)
                            Text("选项 2").tag(2)
                            Text("选项 3").tag(3)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Liquid Glass 验证")
    }
}

// 辅助函数 - 根据颜色名称获取颜色
func getColor(for name: String) -> Color {
    switch name {
    case "红":
        return .red
    case "绿":
        return .green
    case "蓝":
        return .blue
    case "黄":
        return .yellow
    case "紫":
        return .purple
    case "橙":
        return .orange
    default:
        return .gray
    }
}

// 辅助函数 - 根据背景颜色获取对比色
func getContrastColor(for name: String) -> Color {
    switch name {
    case "黄":
        return .black  // 黄色背景上使用黑色文本
    default:
        return .white  // 其他颜色背景上使用白色文本
    }
}

// 颜色卡片组件
struct ColorCard: View {
    let color: Color
    let name: String

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 40)

            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

struct LiquidGlassValidationView_Previews: PreviewProvider {
    static var previews: some View {
        LiquidGlassValidationView()
            .environment(\.themeService, ThemeService.shared)
            .environment(\.layoutService, LayoutService.shared)
    }
}