// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XIconAI",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "XIconAI",
            targets: ["XIconAI"]
        )
    ],
    dependencies: [
        // 网络请求和数据处理
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),

        // JSON 解析
        .package(url: "https://github.com/Flight-School/AnyCodable.git", from: "0.6.0"),

        // 图像处理
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.2.0"),

        // 日志记录
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),

        // 加密和安全
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),

        // 文件压缩
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0"),

        // 键值存储
        .package(url: "https://github.com/sindresorhus/Defaults.git", from: "7.3.0"),

        // 测试工具
        .package(url: "https://github.com/Quick/Quick.git", from: "7.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "12.0.0")
    ],
    targets: [
        .executableTarget(
            name: "XIconAI",
            dependencies: [
                "Alamofire",
                "AnyCodable",
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Crypto", package: "swift-crypto"),
                "ZIPFoundation",
                "Defaults"
            ],
            path: "Sources",
            resources: [
                .process("Resources"),
                .process("Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "XIconAITests",
            dependencies: [
                "XIconAI",
                "Quick",
                "Nimble"
            ],
            path: "Tests"
        )
    ]
)