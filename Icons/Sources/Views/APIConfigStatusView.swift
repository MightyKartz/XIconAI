//
//  APIConfigStatusView.swift
//  Icons Free Version - API Config Status View
//
//  Created by MightyKartz on 2024/11/18.
//

import SwiftUI

struct APIConfigStatusView: View {
    @ObservedObject var appState: AppState
    let onConfigure: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // 状态指示器
            HStack(spacing: 8) {
                statusIndicator

                VStack(alignment: .leading, spacing: 2) {
                    Text(statusTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 配置按钮
                Button(action: onConfigure) {
                    Text(configureButtonText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(configureButtonColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(10)

            // 详细信息（仅当已配置时显示）
            if appState.isConfigured, let config = appState.apiConfig {
                HStack {
                    Text("提供商: \(config.provider.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if config.provider.isFree {
                        Text("免费")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Computed Properties

    private var statusIndicator: some View {
        Group {
            if appState.isLoading {
                ProgressView()
                    .scaleEffect(0.6)
            } else {
                Image(systemName: appState.isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(appState.isConfigured ? .green : .orange)
            }
        }
        .frame(width: 20, height: 20)
    }

    private var statusTitle: String {
        if appState.isLoading {
            return "检查中..."
        } else if appState.isConfigured {
            return "API已配置"
        } else {
            return "需要配置"
        }
    }

    private var statusMessage: String {
        if appState.isLoading {
            return "正在验证API配置"
        } else if appState.isConfigured {
            guard let config = appState.apiConfig else { return "配置已就绪" }
            return "使用 \(config.provider.displayName)"
        } else {
            return "请先配置AI提供商API"
        }
    }

    private var configureButtonText: String {
        if appState.isConfigured {
            return "重新配置"
        } else {
            return "配置"
        }
    }

    private var configureButtonColor: Color {
        if appState.isConfigured {
            return .blue
        } else {
            return .orange
        }
    }

    private var backgroundColor: Color {
        if appState.isConfigured {
            return Color.green.opacity(0.1)
        } else {
            return Color.orange.opacity(0.1)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 未配置状态
        APIConfigStatusView(appState: AppState()) {
            print("Configure tapped")
        }

        // 已配置状态
        APIConfigStatusView(appState: {
            let state = AppState()
            state.isConfigured = true
            state.apiConfig = APIConfig(
                provider: .modelscope,
                apiKey: "test-key",
                model: "Qwen-Image"
            )
            return state
        }()) {
            print("Reconfigure tapped")
        }
    }
    .padding()
}