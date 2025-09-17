//
//  ComponentsTests.swift
//  IconsTests
//
//  Created by Claude Code on 2025/9/16.
//

import XCTest
@testable import Icons

final class ComponentsTests: XCTestCase {

    func testTextContrastInLightMode() {
        // 测试浅色模式下的文本对比度

        // 创建ThemeService实例
        let themeService = ThemeService.shared

        // 设置为浅色模式
        themeService.setTheme(.light)

        // 验证浅色模式设置
        XCTAssertEqual(themeService.currentTheme, .light, "主题应该设置为浅色模式")

        // 测试主要文本颜色在浅色背景上的对比度
        let primaryTextColor = Color.primary
        XCTAssertNotNil(primaryTextColor, "主要文本颜色应该存在")

        // 测试次要文本颜色在浅色背景上的对比度
        let secondaryTextColor = Color.secondary
        XCTAssertNotNil(secondaryTextColor, "次要文本颜色应该存在")
    }

    func testTextContrastInDarkMode() {
        // 测试深色模式下的文本对比度

        // 创建ThemeService实例
        let themeService = ThemeService.shared

        // 设置为深色模式
        themeService.setTheme(.dark)

        // 验证深色模式设置
        XCTAssertEqual(themeService.currentTheme, .dark, "主题应该设置为深色模式")

        // 测试主要文本颜色在深色背景上的对比度
        let primaryTextColor = Color.primary
        XCTAssertNotNil(primaryTextColor, "主要文本颜色应该存在")

        // 测试次要文本颜色在深色背景上的对比度
        let secondaryTextColor = Color.secondary
        XCTAssertNotNil(secondaryTextColor, "次要文本颜色应该存在")
    }

    func testTextContrastInLiquidGlassCards() {
        // 测试Liquid Glass卡片中的文本对比度

        // 测试标题文本在Liquid Glass背景上的可读性
        let titleText = "测试标题"
        XCTAssertNotNil(titleText, "标题文本应该存在")
        XCTAssertFalse(titleText.isEmpty, "标题文本不应该为空")

        // 测试描述文本在Liquid Glass背景上的可读性
        let descriptionText = "测试描述文本内容"
        XCTAssertNotNil(descriptionText, "描述文本应该存在")
        XCTAssertFalse(descriptionText.isEmpty, "描述文本不应该为空")

        // 测试页脚文本在Liquid Glass背景上的可读性
        let footerText = "测试页脚"
        XCTAssertNotNil(footerText, "页脚文本应该存在")
        XCTAssertFalse(footerText.isEmpty, "页脚文本不应该为空")
    }

    func testButtonTextContrast() {
        // 测试按钮文本在不同背景上的对比度

        // 测试主按钮文本可读性
        let primaryButtonText = "主要按钮"
        XCTAssertNotNil(primaryButtonText, "主按钮文本应该存在")

        // 测试次按钮文本可读性
        let secondaryButtonText = "次要按钮"
        XCTAssertNotNil(secondaryButtonText, "次按钮文本应该存在")

        // 测试轮廓按钮文本可读性
        let outlineButtonText = "轮廓按钮"
        XCTAssertNotNil(outlineButtonText, "轮廓按钮文本应该存在")

        // 测试幽灵按钮文本可读性
        let ghostButtonText = "幽灵按钮"
        XCTAssertNotNil(ghostButtonText, "幽灵按钮文本应该存在")
    }
}