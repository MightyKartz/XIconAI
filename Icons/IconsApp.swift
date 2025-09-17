//
//  IconsApp.swift
//  Icons
//
//  Created by kartz on 2025/1/11.
//

import SwiftUI

#if !DEV_CLI
@main
@MainActor
struct IconsApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var themeService = ThemeService.shared
    @StateObject private var layoutService = LayoutService.shared
    @StateObject private var interactionService = InteractionService.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainNavigationView()
                .environmentObject(appState)
                .environmentObject(themeService)
                .environmentObject(layoutService)
                .environmentObject(interactionService)
                .preferredColorScheme(themeService.getColorScheme())
                .accentColor(themeService.accentColor.color)
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    // 启动时尝试执行每日清理
                    IconService.shared.runDailyCleanupIfNeeded()
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            AppCommands()
        }
        .onChange(of: scenePhase) { newPhase in
            // 应用回到前台时再次检查是否需要执行清理
            if newPhase == .active {
                IconService.shared.runDailyCleanupIfNeeded()
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(appState)
                .environmentObject(themeService)
                .environmentObject(layoutService)
                .environmentObject(interactionService)
        }
    }
}
#endif

/// 应用菜单命令
struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("新建模板...") {
                // TODO: 实现新建模板功能
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
            
            Button("导入模板...") {
                // TODO: 实现导入模板功能
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])
        }
        
        CommandGroup(after: .importExport) {
            Button("导出历史...") {
                // TODO: 实现导出历史功能
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
        }
    }
}
