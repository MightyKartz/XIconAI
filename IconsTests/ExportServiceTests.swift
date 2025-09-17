import XCTest
@testable import Icons

final class ExportServiceTests: XCTestCase {

    func testConfiguredSizeSpecsOrFallback_iOSCount() throws {
        let specs = AppIconPlatform.iOS.sizeSpecs
        // 至少包含常见 18 个条目（iPhone 8 + iPad 9 + marketing 1）
        XCTAssertGreaterThanOrEqual(specs.count, 18, "iOS 尺寸规格数量应不少于 18")
        XCTAssertTrue(specs.contains(where: { $0.idiom == "ios-marketing" && $0.size == "1024x1024" && $0.scale == "1x" }), "应包含 App Store 营销图标 1024x1024")
    }

    func testConfiguredSizeSpecsOrFallback_macOSCount() throws {
        let specs = AppIconPlatform.macOS.sizeSpecs
        XCTAssertGreaterThanOrEqual(specs.count, 10, "macOS 尺寸规格数量应不少于 10（含 @2x）")
    }

    func testConfiguredSizeSpecsOrFallback_watchOSCount() throws {
        let specs = AppIconPlatform.watchOS.sizeSpecs
        XCTAssertGreaterThanOrEqual(specs.count, 8, "watchOS 尺寸规格数量应不少于 8（含 marketing）")
    }

    func testConfiguredSizeSpecsOrFallback_tvOSCount() throws {
        let specs = AppIconPlatform.tvOS.sizeSpecs
        XCTAssertGreaterThanOrEqual(specs.count, 4, "tvOS 尺寸规格数量应不少于 4")
    }

    func testPixelSizeCalculation() throws {
        let spec = AppIconSizeSpec(size: "60x60", scale: "3x", idiom: "iphone", filename: "Icon-60@3x.png")
        let px = spec.pixelSize
        XCTAssertEqual(Int(px.width), 180)
        XCTAssertEqual(Int(px.height), 180)
    }

    func testGenerateContentsJSONStructure() throws {
        // 使用 iOS 的规格作为输入，验证生成的 JSON 结构
        let specs = AppIconPlatform.iOS.sizeSpecs
        let json = ExportService.shared.generateContentsJSON(for: specs, platform: .iOS)
        // 校验 images 数组存在且非空
        guard let images = json["images"] as? [[String: Any]] else {
            return XCTFail("images 节点缺失或类型不匹配")
        }
        XCTAssertFalse(images.isEmpty, "images 不应为空")
        // 校验 info 节点
        guard let info = json["info"] as? [String: Any] else {
            return XCTFail("info 节点缺失或类型不匹配")
        }
        XCTAssertEqual(info["author"] as? String, "Icons App")
        XCTAssertEqual(info["version"] as? Int, 1)
        // 抽样校验一个常见条目
        let hasIphone60x3x = images.contains { item in
            (item["size"] as? String) == "60x60" &&
            (item["scale"] as? String) == "3x" &&
            (item["idiom"] as? String) == "iphone" &&
            (item["filename"] as? String) == "Icon-60@3x.png"
        }
        XCTAssertTrue(hasIphone60x3x, "应包含 iPhone 60x60 @3x 条目")
    }

    func testExportAsAppIconSetWritesFiles() async throws {
        // 1) 在临时目录生成一张 1024x1024 的测试图片，并持久化为 PNG
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("IconsTests_Export_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        let testImageURL = tmpDir.appendingPathComponent("base.png")
        try createTestImage(size: CGSize(width: 1024, height: 1024), color: .systemBlue).write(to: testImageURL)

        // 2) 组装一个 GeneratedIcon，优先通过 localPath 加载
        let icon = GeneratedIcon(
            prompt: "Unit Test AppIcon",
            templateId: nil,
            imageURL: "https://example.invalid/unused.png", // 不会被用到
            localPath: testImageURL.path,
            size: CGSize(width: 1024, height: 1024),
            format: "png",
            model: "local-test",
            parameters: [:],
            isFavorite: false,
            tags: []
        )

        // 3) 导出到目标目录，选择 iOS 平台生成 .appiconset
        let outDir = tmpDir.appendingPathComponent("out")
        try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
        try await ExportService.shared.exportAsAppIconSet(icon, to: outDir, platform: .iOS)

        // 4) 断言：生成了 .appiconset 目录和 Contents.json
        let baseName = ExportService.sanitizeFileName(icon.prompt.isEmpty ? icon.id.uuidString : icon.prompt)
        let appiconsetURL = outDir.appendingPathComponent("\(baseName).appiconset")

        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: appiconsetURL.path, isDirectory: &isDirectory) && isDirectory.boolValue, ".appiconset 目录不存在")

        let contentsURL = appiconsetURL.appendingPathComponent("Contents.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: contentsURL.path), "Contents.json 未生成")

        // 5) 抽样检查一个常见文件是否存在（iPhone 60x60 @3x）
        let expectedIphone60x3x = appiconsetURL.appendingPathComponent("Icon-60@3x.png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedIphone60x3x.path), "未找到 Icon-60@3x.png（抽样检查）")
    }

    // 生成纯色 PNG 图片数据
    private func createTestImage(size: CGSize, color: NSColor) -> Data {
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
        image.unlockFocus()

        // 将 NSImage 转 PNG Data
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let rep = NSBitmapImageRep(cgImage: cgImage)
        let pngData = rep.representation(using: .png, properties: [:])!
        return pngData
    }
}