//
//  DevHostMain.swift
//  Icons (Dev CLI Host)
//
//  Created by automation.
//

#if DEV_CLI
import AppKit
import SwiftUI

@main
struct DevHostMain {
    @MainActor
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.regular)

        // Prepare environment singletons
        let appState = AppState.shared
        let themeService = ThemeService.shared
        let layoutService = LayoutService.shared
        let interactionService = InteractionService.shared

        // DEV: 仅在开发主机下注入一些示例模板，方便做模板浏览/预览的可视回归
        if appState.templates.isEmpty {
            appState.templates = [
                PromptTemplate(
                    name: "App 图标 · 极简",
                    category: .minimalist,
                    content: "Design a minimal, flat-style app icon for {app_name}, primary color {color}, clean lines, subtle shadows, high contrast, vector-friendly.",
                    description: "极简风格的通用应用图标模板，强调干净的几何形与高对比度。",
                    tags: ["minimal", "flat", "vector"],
                    parameters: [
                        TemplateParameter(
                            name: "app_name",
                            displayName: "应用名称",
                            type: .text,
                            defaultValue: "Nova",
                            placeholder: "请输入应用名称",
                            isRequired: true
                        ),
                        TemplateParameter(
                            name: "color",
                            displayName: "主色",
                            type: .color,
                            defaultValue: "#2F80ED",
                            placeholder: "#RRGGBB"
                        )
                    ],
                    isBuiltIn: true,
                    popularity: 12,
                    usageCount: 3,
                    examples: [
                        "A minimal, flat-style app icon for Nova, primary color #2F80ED, clean geometric shapes, subtle inner shadows"
                    ]
                ),
                PromptTemplate(
                    name: "商务 · 蓝金",
                    category: .business,
                    content: "Create a professional business icon featuring {symbol}, navy blue and gold palette, premium feel, subtle gradients, crisp edges.",
                    description: "偏商务气质的图标模板，适合金融/企业类场景。",
                    tags: ["business", "gold", "premium"],
                    parameters: [
                        TemplateParameter(
                            name: "symbol",
                            displayName: "SF Symbol",
                            type: .text,
                            defaultValue: "chart.bar",
                            placeholder: "例如 chart.bar"
                        ),
                        TemplateParameter(
                            name: "style",
                            displayName: "风格",
                            type: .select,
                            defaultValue: "gradient",
                            options: ["flat", "gradient", "glassmorphism"]
                        )
                    ],
                    isBuiltIn: true,
                    popularity: 8,
                    usageCount: 2
                ),
                PromptTemplate(
                    name: "创意 · 霓虹",
                    category: .creative,
                    content: "Design a creative neon-style icon with glowing edges, {mood} mood, intense colors, dark background, high contrast.",
                    description: "具有霓虹辉光效果的创意图标模板。",
                    tags: ["creative", "neon", "glow"],
                    parameters: [
                        TemplateParameter(
                            name: "mood",
                            displayName: "情绪",
                            type: .select,
                            defaultValue: "vibrant",
                            options: ["vibrant", "calm", "playful"]
                        )
                    ],
                    isBuiltIn: true,
                    popularity: 10,
                    usageCount: 1
                )
            ]
        }

        // Build root view with environment objects
        let rootView = MainNavigationView()
            .environmentObject(appState)
            .environmentObject(themeService)
            .environmentObject(layoutService)
            .environmentObject(interactionService)
            .preferredColorScheme(themeService.getColorScheme())
            .accentColor(themeService.accentColor.color)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 800),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Icons Dev"
        window.contentView = NSHostingView(rootView: rootView)
        window.makeKeyAndOrderFront(nil)

        app.activate(ignoringOtherApps: true)
        app.run()
    }
}
#endif