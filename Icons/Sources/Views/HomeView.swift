//
//  HomeView.swift
//  Icons Free Version - Home View
//
//  Created by MightyKartz on 2024/11/18.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 欢迎区域
                welcomeSection

                // 功能特性
                featuresSection

                // 快速开始
                quickStartSection

                // 状态信息
                statusSection

                Spacer()
            }
            .padding()
        }
        .navigationTitle("主页")
    }

    // MARK: - Welcome Section

    private var welcomeSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("欢迎使用 Icons")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("免费开源的AI图标生成工具")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("使用先进的AI技术，快速生成高质量的图标设计")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("功能特点")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                FeatureCard(
                    icon: "brain.head.profile",
                    title: "多AI提供商",
                    description: "支持OpenAI、ModelScope等多个AI服务",
                    color: .blue
                )

                FeatureCard(
                    icon: "lock.shield",
                    title: "隐私保护",
                    description: "API密钥本地加密存储，数据不上传服务器",
                    color: .green
                )

                FeatureCard(
                    icon: "bolt.circle",
                    title: "快速生成",
                    description: "秒级响应，实时预览生成效果",
                    color: .orange
                )

                FeatureCard(
                    icon: "square.and.arrow.down",
                    title: "多格式导出",
                    description: "支持PNG、SVG等多种格式导出",
                    color: .purple
                )
            }
        }
    }

    // MARK: - Quick Start Section

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("快速开始")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                QuickStartStep(
                    number: 1,
                    title: "配置API",
                    description: "在设置中配置您选择的AI提供商API密钥"
                )

                QuickStartStep(
                    number: 2,
                    title: "输入描述",
                    description: "在生成页面输入您想要的图标描述"
                )

                QuickStartStep(
                    number: 3,
                    title: "生成图标",
                    description: "点击生成按钮，AI将为您创建独特的图标"
                )
            }
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        VStack(spacing: 16) {
            Text("当前状态")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                StatusRow(
                    icon: "key.fill",
                    title: "API配置",
                    value: appState.isConfigured ? "已配置" : "未配置",
                    color: appState.isConfigured ? .green : .red
                )

                StatusRow(
                    icon: "clock.fill",
                    title: "生成历史",
                    value: "\(appState.generationHistory.count) 个记录",
                    color: .blue
                )

                if let errorMessage = appState.errorMessage {
                    StatusRow(
                        icon: "exclamationmark.triangle.fill",
                        title: "错误信息",
                        value: errorMessage,
                        color: .red
                    )
                }
            }
        }
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(10)

            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Quick Start Step

struct QuickStartStep: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Text("\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Status Row

struct StatusRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)

            Text(title)
                .font(.subheadline)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundColor(color)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationView {
        HomeView(appState: AppState())
    }
}