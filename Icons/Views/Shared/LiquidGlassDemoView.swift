import SwiftUI

/// Demo view showcasing Liquid Glass effects for macOS 26
struct LiquidGlassDemoView: View {
    @Environment(\.themeService) var themeService

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text("Liquid Glass Effect")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("展示 macOS 26 的全新 Liquid Glass 材料效果")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Standard Card vs Liquid Glass Card
                HStack(spacing: 20) {
                    CardView(
                        title: "标准卡片",
                        description: "这是使用标准材料的卡片"
                    ) {
                        Text("标准卡片内容")
                            .font(.body)
                    }

                    CardView(
                        title: "Liquid Glass 卡片",
                        description: "这是使用 Liquid Glass 效果的卡片",
                        useLiquidGlass: true
                    ) {
                        Text("Liquid Glass 卡片内容")
                            .font(.body)
                    }
                }

                // Button Styles Comparison
                CardView(
                    title: "按钮样式对比",
                    description: "比较标准按钮与 Liquid Glass 按钮"
                ) {
                    VStack(spacing: 15) {
                        // Primary Buttons
                        HStack(spacing: 20) {
                            Button("标准主按钮") {}
                                .primaryStyle()

                            Button("Liquid Glass 主按钮") {}
                                .primaryStyle()
                                .environment(\.liquidGlassEffect, true)
                        }

                        // Secondary Buttons
                        HStack(spacing: 20) {
                            Button("标准次按钮") {}
                                .secondaryStyle()

                            Button("Liquid Glass 次按钮") {}
                                .secondaryStyle()
                                .environment(\.liquidGlassEffect, true)
                        }

                        // Outline Buttons
                        HStack(spacing: 20) {
                            Button("标准轮廓按钮") {}
                                .outlineStyle()

                            Button("Liquid Glass 轮廓按钮") {}
                                .outlineStyle()
                                .environment(\.liquidGlassEffect, true)
                        }
                    }
                }

                // Interactive Demo
                CardView(
                    title: "交互式演示",
                    description: "尝试不同的 Liquid Glass 效果设置"
                ) {
                    VStack(spacing: 20) {
                        Button("点击我体验 Liquid Glass") {
                            // 按钮点击效果
                        }
                        .primaryStyle()
                        .environment(\.liquidGlassEffect, true)
                        .padding(.vertical)

                        Text("Liquid Glass 效果会在浅色模式下更加明显")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Liquid Glass 演示")
    }
}

struct LiquidGlassDemoView_Previews: PreviewProvider {
    static var previews: some View {
        LiquidGlassDemoView()
            .environment(\.themeService, ThemeService.shared)
    }
}