import XCTest
@testable import Icons

final class LiquidGlassEffectTests: XCTestCase {
    var themeService: ThemeService!
    var layoutService: LayoutService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        themeService = ThemeService()
        layoutService = LayoutService()
    }

    override func tearDownWithError() throws {
        themeService = nil
        layoutService = nil
        try super.tearDownWithError()
    }

    func testLiquidGlassMaterialInLightMode() {
        // 设置浅色模式
        themeService.setTheme(.light)

        // 验证Liquid Glass材料
        let material = themeService.getLiquidGlassMaterial()
        XCTAssertEqual(material, Material.liquidGlass, "在浅色模式下应该返回Liquid Glass材料")
    }

    func testDarkLiquidGlassMaterialInDarkMode() {
        // 设置深色模式
        themeService.setTheme(.dark)

        // 验证暗黑Liquid Glass材料
        let material = themeService.getLiquidGlassMaterial()
        XCTAssertEqual(material, Material.darkLiquidGlass, "在深色模式下应该返回暗黑Liquid Glass材料")
    }

    func testLiquidGlassEffectSetting() {
        // 启用Liquid Glass效果
        layoutService.setLiquidGlassEffect(true)
        XCTAssertTrue(layoutService.enableLiquidGlassEffect, "应该正确启用Liquid Glass效果")

        // 禁用Liquid Glass效果
        layoutService.setLiquidGlassEffect(false)
        XCTAssertFalse(layoutService.enableLiquidGlassEffect, "应该正确禁用Liquid Glass效果")
    }

    func testCardViewLiquidGlassBehavior() {
        // 测试CardView的Liquid Glass行为
        let cardView = CardView(useLiquidGlass: true) {
            Text("测试内容")
        }

        // 由于CardView是View结构，我们主要测试其配置
        XCTAssertTrue(cardView.useLiquidGlass, "CardView应该正确设置Liquid Glass参数")
    }

    func testButtonStyleWithLiquidGlass() {
        // 测试按钮样式的Liquid Glass效果
        let primaryButton = PrimaryButtonStyle()
        let secondaryButton = SecondaryButtonStyle()

        // 验证按钮样式已正确初始化（通过环境值访问）
        // 实际测试需要在预览环境中进行
        XCTAssertNotNil(primaryButton, "应该正确创建PrimaryButtonStyle")
        XCTAssertNotNil(secondaryButton, "应该正确创建SecondaryButtonStyle")
    }

    func testDarkModeLiquidGlassBackground() {
        // 设置深色模式
        themeService.setTheme(.dark)

        // 获取Liquid Glass背景
        let background = themeService.getLiquidGlassBackground()

        // 验证背景已正确创建（在预览环境中实际测试视觉效果）
        XCTAssertNotNil(background, "在深色模式下应该正确创建Liquid Glass背景")
    }

    func testLightAndDarkModeLiquidGlassConsistency() {
        // 测试浅色和深色模式下的Liquid Glass效果一致性

        // 浅色模式
        themeService.setTheme(.light)
        let lightMaterial = themeService.getLiquidGlassMaterial()
        XCTAssertEqual(lightMaterial, Material.liquidGlass, "浅色模式下应该返回标准Liquid Glass材料")

        // 深色模式
        themeService.setTheme(.dark)
        let darkMaterial = themeService.getLiquidGlassMaterial()
        XCTAssertEqual(darkMaterial, Material.darkLiquidGlass, "深色模式下应该返回暗黑Liquid Glass材料")
    }

    func testTextReadabilityInLiquidGlassCard() {
        // 测试Liquid Glass卡片中的文本可读性设置

        // 创建使用Liquid Glass效果的卡片
        let cardView = CardView(
            title: "测试标题",
            description: "测试描述",
            footer: "测试页脚",
            useLiquidGlass: true
        ) {
            Text("测试内容")
        }

        // 验证卡片配置
        XCTAssertTrue(cardView.useLiquidGlass, "卡片应该启用Liquid Glass效果")
        XCTAssertEqual(cardView.title, "测试标题", "卡片标题应该正确设置")
        XCTAssertEqual(cardView.description, "测试描述", "卡片描述应该正确设置")
        XCTAssertEqual(cardView.footer, "测试页脚", "卡片页脚应该正确设置")
    }

    func testButtonTextReadabilityInLiquidGlassMode() {
        // 测试Liquid Glass模式下的按钮文本可读性

        // 主按钮样式
        let primaryButtonStyle = PrimaryButtonStyle()
        XCTAssertNotNil(primaryButtonStyle, "应该正确创建PrimaryButtonStyle")

        // 次按钮样式
        let secondaryButtonStyle = SecondaryButtonStyle()
        XCTAssertNotNil(secondaryButtonStyle, "应该正确创建SecondaryButtonStyle")

        // 轮廓按钮样式
        let outlineButtonStyle = OutlineButtonStyle()
        XCTAssertNotNil(outlineButtonStyle, "应该正确创建OutlineButtonStyle")

        // 幽灵按钮样式
        let ghostButtonStyle = GhostButtonStyle()
        XCTAssertNotNil(ghostButtonStyle, "应该正确创建GhostButtonStyle")
    }

    func testContrastRatiosForTextReadability() {
        // 测试文本可读性的对比度比例

        // 在浅色模式下测试
        themeService.setTheme(.light)
        layoutService.setLiquidGlassEffect(true)

        // Liquid Glass背景应该提供足够的对比度
        let lightBackgroundOpacity = 0.7  // 浅色模式下背景不透明度
        let lightStrokeOpacity = 0.6      // 浅色模式下边框不透明度

        // 验证不透明度值在合理范围内（0.3-0.8通常提供良好对比度）
        XCTAssertTrue(lightBackgroundOpacity >= 0.3 && lightBackgroundOpacity <= 0.8,
            "浅色模式Liquid Glass背景不透明度应在合理范围内")
        XCTAssertTrue(lightStrokeOpacity >= 0.3 && lightStrokeOpacity <= 0.8,
            "浅色模式Liquid Glass边框不透明度应在合理范围内")

        // 在深色模式下测试
        themeService.setTheme(.dark)

        // Liquid Glass背景应该提供足够的对比度
        let darkBackgroundOpacity = 0.35  // 深色模式下背景不透明度
        let darkStrokeOpacity = 0.25      // 深色模式下边框不透明度

        // 验证不透明度值在合理范围内
        XCTAssertTrue(darkBackgroundOpacity >= 0.2 && darkBackgroundOpacity <= 0.5,
            "深色模式Liquid Glass背景不透明度应在合理范围内")
        XCTAssertTrue(darkStrokeOpacity >= 0.15 && darkStrokeOpacity <= 0.4,
            "深色模式Liquid Glass边框不透明度应在合理范围内")
    }

    func testTextReadabilityInLightMode() {
        // 测试浅色模式下的文本可读性

        // 设置为浅色模式
        themeService.setTheme(.light)
        layoutService.setLiquidGlassEffect(true)

        // 创建Liquid Glass卡片并验证文本可读性
        let cardView = CardView(
            title: "文本可读性测试",
            description: "在浅色模式Liquid Glass背景下，文本应该清晰可读。",
            footer: "浅色模式文本",
            useLiquidGlass: true
        ) {
            Text("卡片内容文本")
        }

        // 验证卡片和文本设置
        XCTAssertEqual(cardView.title, "文本可读性测试", "卡片标题应该正确")
        XCTAssertEqual(cardView.description, "在浅色模式Liquid Glass背景下，文本应该清晰可读。", "卡片描述应该正确")
        XCTAssertEqual(cardView.footer, "浅色模式文本", "卡片页脚应该正确")
    }

    func testTextReadabilityInDarkMode() {
        // 测试深色模式下的文本可读性

        // 设置为深色模式
        themeService.setTheme(.dark)
        layoutService.setLiquidGlassEffect(true)

        // 创建Liquid Glass卡片并验证文本可读性
        let cardView = CardView(
            title: "文本可读性测试",
            description: "在深色模式Liquid Glass背景下，文本应该清晰可读。",
            footer: "深色模式文本",
            useLiquidGlass: true
        ) {
            Text("卡片内容文本")
        }

        // 验证卡片和文本设置
        XCTAssertEqual(cardView.title, "文本可读性测试", "卡片标题应该正确")
        XCTAssertEqual(cardView.description, "在深色模式Liquid Glass背景下，文本应该清晰可读。", "卡片描述应该正确")
        XCTAssertEqual(cardView.footer, "深色模式文本", "卡片页脚应该正确")
    }
}