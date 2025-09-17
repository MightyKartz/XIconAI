//
//  DeveloperOptionsView.swift
//  Icons
//
//  Created by Icons Team
//

import SwiftUI

/// 开发者测试选项视图 - 仅在DEBUG模式下可见
struct DeveloperOptionsView: View {
    @AppStorage("freeUnlimitedUsage") private var freeUnlimitedUsage: Bool = false
    @AppStorage("isProUser") private var isProUser: Bool = false
    @State private var showingResetAlert = false
    
    // 新增：调试请求头选项

    
    var body: some View {
        #if DEBUG
        VStack(alignment: .leading, spacing: 16) {
            // 标题区域
            HStack {
                Image(systemName: "hammer.fill")
                    .foregroundColor(.blue)
                Text("开发者测试选项")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                Text("DEBUG")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                    .foregroundColor(.blue)
            }
            
            Text("这些选项仅在开发环境中可见，用于测试不同的用户状态和功能。")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Divider()
            
            // 免费用户无限次使用选项
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Toggle("免费用户无限次使用", isOn: $freeUnlimitedUsage)
                        .toggleStyle(SwitchToggleStyle())
                    Spacer()
                }
                
                Text("启用后，免费用户将绕过每日配额限制，可以无限次生成图标。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
            
            // Pro用户功能选项
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Toggle("启用Pro功能", isOn: $isProUser)
                        .toggleStyle(SwitchToggleStyle())
                    Spacer()
                }
                
                Text("启用后，用户将获得Pro级别的功能访问权限，包括高分辨率生成、无水印等。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
            
            Divider()
            

            
            // 重置按钮
            HStack {
                Spacer()
                Button("重置所有开发者选项") {
                    showingResetAlert = true
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
        .alert("重置开发者选项", isPresented: $showingResetAlert) {
            Button("取消", role: .cancel) { }
            Button("重置", role: .destructive) {
                resetDeveloperOptions()
            }
        } message: {
            Text("确定要重置所有开发者测试选项吗？这将关闭所有测试功能。")
        }
        .onChange(of: freeUnlimitedUsage) { newValue in
            handleFreeUnlimitedUsageChange(newValue)
        }
        .onChange(of: isProUser) { newValue in
            handleProUserChange(newValue)
        }
        #else
        EmptyView()
        #endif
    }
    
    // MARK: - 私有方法
    
    private func resetDeveloperOptions() {
        freeUnlimitedUsage = false
        isProUser = false
        
        // 清除设备UUID
        UserDefaults.standard.removeObject(forKey: "devDeviceUUID")
        
        print("🔧 [Developer] Reset all developer options to defaults")
    }
    
    private func handleFreeUnlimitedUsageChange(_ enabled: Bool) {
        if enabled {
            print("🔧 [Developer] Free unlimited usage enabled - quota checks will be bypassed")
        } else {
            print("🔧 [Developer] Free unlimited usage disabled - normal quota checks will apply")
        }
    }
    
    private func handleProUserChange(_ enabled: Bool) {
        if enabled {
            print("🔧 [Developer] Pro user mode enabled - Pro features unlocked")
        } else {
            print("🔧 [Developer] Pro user mode disabled - back to free user features")
        }
    }
}

#Preview {
    DeveloperOptionsView()
        .frame(width: 400)
}