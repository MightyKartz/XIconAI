import SwiftUI

/// Liquid Glass 效果展示视图 - 测试文本可读性和视觉效果
struct LiquidGlassShowcaseView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeService) var themeService

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 标题部分
                VStack(alignment: .leading, spacing: 8) {
                    Text("Liquid Glass 效果展示")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("验证文本可读性和视觉效果")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)

                // 对比卡片 - 验证文本可读性
                HStack(spacing: 20) {
                    // 标准卡片
                    CardView(
                        title: "标准卡片",
                        description: "这是使用标准背景的卡片组件展示"
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("在标准卡片中，文本具有良好的对比度和可读性。")

                            Button("标准按钮") {}
                                .primaryStyle()
                        }
                    }

                    // Liquid Glass 卡片
                    CardView(
                        title: "Liquid Glass 卡片",
                        description: "这是使用 Liquid Glass 效果的卡片组件展示",
                        useLiquidGlass: true
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("在 Liquid Glass 卡片中，文本同样保持了良好的可读性，同时具有独特的视觉效果。")

                            Button("Glass 按钮") {}
                                .primaryStyle()
                                .environment(\.liquidGlassEffect, true)
                        }
                    }
                }

                // 按钮样式对比 - 验证文本可读性
                CardView(
                    title: "按钮样式对比",
                    description: "比较不同按钮样式下的文本可读性"
                ) {
                    VStack(spacing: 15) {
                        // 主要按钮对比
                        VStack(alignment: .leading, spacing: 8) {
                            Text("主要按钮")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            HStack(spacing: 15) {
                                Button("标准主按钮") {}
                                    .primaryStyle()

                                Button("Liquid Glass 主按钮") {}
                                    .primaryStyle()
                                    .environment(\.liquidGlassEffect, true)
                            }
                        }

                        Divider()

                        // 次要按钮对比
                        VStack(alignment: .leading, spacing: 8) {
                            Text("次要按钮")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            HStack(spacing: 15) {
                                Button("标准次按钮") {}
                                    .secondaryStyle()

                                Button("Liquid Glass 次按钮") {}
                                    .secondaryStyle()
                                    .environment(\.liquidGlassEffect, true)
                            }
                        }
                    }
                }

                // 文本颜色测试
                CardView(
                    title: "文本可读性测试",
                    description: "验证在 Liquid Glass 背景上的文本可读性",
                    useLiquidGlass: true
                ) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("主要文本 - 高对比度")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("次要文本 - 中等对比度")
                            .font(.body)
                            .foregroundStyle(.secondary)

                        Text("三级文本 - 低对比度")
                            .font(.caption)
                            .foregroundStyle(.tertiary)

                        Text("链接文本 - 可交互元素")
                            .font(.body)
                            .foregroundStyle(Color.accentColor)
                    }
                }

                // 不同背景下的文本测试
                VStack(spacing: 15) {
                    Text("不同背景下的文本可读性")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 浅色背景上的文本
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                            .cornerRadius(8)
                            .frame(width: 100, height: 60)

                        VStack(alignment: .leading) {
                            Text("浅色背景")
                                .font(.headline)
                            Text("文本可读性良好")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        BlurView(material: .hudWindow)
                            .opacity(0.5)
                    )
                    .cornerRadius(12)

                    // 深色背景上的文本
                    HStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(8)
                            .frame(width: 100, height: 60)

                        VStack(alignment: .leading) {
                            Text("深色背景")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("文本可读性良好")
                                .font(.subheadline)
                                .foregroundStyle(Color.white.opacity(0.7))
                        }
                    }
                    .padding()
                    .background(
                        BlurView(material: .hudWindow)
                            .opacity(0.7)
                    )
                    .cornerRadius(12)
                }
                .padding()
                .background(themeService.getLiquidGlassBackground())
                .cornerRadius(16)
            }
            .padding()
        }
        .navigationTitle("Liquid Glass 展示")
    }
}

struct LiquidGlassShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        LiquidGlassShowcaseView()
            .environment(\.themeService, ThemeService.shared)
    }
}