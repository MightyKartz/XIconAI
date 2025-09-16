//
//  SharedComponents.swift
//  Icons
//
//  Created by Icons Team
//

import SwiftUI

/// 分类芯片
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.accentColor : Color(.controlBackgroundColor))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

/// 主题切换视图 - 提供直观的主题切换体验
struct ThemeToggleView: View {
    @EnvironmentObject private var themeService: ThemeService
    @EnvironmentObject private var interactionService: InteractionService

    var body: some View {
        HStack(spacing: 12) {
            ForEach(AppTheme.allCases) { theme in
                ThemeToggleButton(
                    theme: theme,
                    isSelected: themeService.currentTheme == theme
                ) {
                    withAnimation(interactionService.buttonPressAnimation()) {
                        themeService.setTheme(theme)
                    }
                    interactionService.buttonPressed()
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

/// 主题切换按钮 - 单个主题选项按钮
struct ThemeToggleButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    @EnvironmentObject private var interactionService: InteractionService
    @State private var isHovered = false

    private var iconColor: Color {
        switch theme {
        case .light:
            return .orange
        case .dark:
            return .indigo
        case .system:
            return .blue
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: theme.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(iconColor)

                Text(theme.displayName)
                    .font(.caption2)
                    .foregroundColor(textColor)
            }
            .frame(width: 50, height: 50)
            .background(backgroundView)
            .cornerRadius(8)
            .accessibilityLabel(theme.displayName)
            .accessibilityHint("选择\(theme.displayName)主题")
            .accessibilityValue(isSelected ? "已选择" : "未选择")
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(interactionService.scaleAnimation()) {
                isHovered = hovering
            }
        }
        .scaleEffect(isHovered ? 1.05 : 1.0)
    }

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: isSelected ? 3 : 0)
            )
    }

    private var backgroundColor: Color {
        if isSelected {
            return iconColor.opacity(0.25)  // Increased opacity for better visual feedback
        } else if isHovered {
            return Color(NSColor.controlAccentColor).opacity(0.12)  // Increased opacity
        } else {
            return Color.clear
        }
    }

    private var borderColor: Color {
        isSelected ? iconColor : Color.clear
    }

    private var textColor: Color {
        if isSelected {
            return iconColor
        } else if isHovered {
            return Color(NSColor.labelColor)
        } else {
            return Color(NSColor.secondaryLabelColor)
        }
    }
}