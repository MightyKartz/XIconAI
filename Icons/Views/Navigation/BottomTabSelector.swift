//
//  BottomTabSelector.swift
//  Icons
//
//  Created by Icons Team
//

import SwiftUI

/// 底部标签选择器 - 用于在模板、SF符号和参数设置之间切换
struct BottomTabSelector: View {
    @Binding var selectedTab: BottomTab
    @EnvironmentObject private var interactionService: InteractionService

    var body: some View {
        HStack(spacing: 20) {
            ForEach(BottomTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(interactionService.slideAnimation()) {
                        selectedTab = tab
                    }
                    interactionService.buttonPressed()
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18))
                        Text(tab.displayName)
                            .font(.caption)
                    }
                    .frame(width: 60, height: 50)
                }
                .buttonStyle(.plain)
                .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    BottomTabSelector(selectedTab: .constant(.templates))
        .environmentObject(InteractionService.shared)
}