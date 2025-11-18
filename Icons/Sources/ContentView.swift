//
//  ContentView.swift
//  Icons Free Version - Main View
//
//  Created by MightyKartz on 2024/11/18.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var selectedTab = NavigationTab.home
    @State private var showingAPIConfig = false

    var body: some View {
        NavigationSplitView {
            // 侧边栏导航
            sidebar
                .navigationSplitViewColumnWidth(
                    min: 200,
                    ideal: 250,
                    max: 300
                )

            // 主内容区域
            mainContent
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            // 应用标题
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("Icons")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Text("免费AI图标生成")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            // 导航选项
            List(NavigationTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    HStack {
                        Image(systemName: tab.icon)
                            .frame(width: 20)
                        Text(tab.title)
                        Spacer()

                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.blue)
                                .frame(width: 3, height: 20)
                        }
                    }
                    .foregroundColor(selectedTab == tab ? .primary : .secondary)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.sidebar)

            Spacer()

            // API配置状态
            APIConfigStatusView(appState: appState) {
                showingAPIConfig = true
            }
        }
        .navigationSplitViewColumnWidth(min: 200, ideal: 250)
    }

    private var mainContent: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeView(appState: appState)
            case .generate:
                GenerateView(appState: appState)
            case .settings:
                SettingsView(appState: appState)
            }
        }
        .sheet(isPresented: $showingAPIConfig) {
            APIConfigView(appState: appState)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}