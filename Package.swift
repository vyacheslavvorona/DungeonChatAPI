// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "DungeonChatAPI",
    products: [
        .library(name: "DungeonChatAPI", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),

        // 👤 Authentication and Authorization framework for Fluent.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/crypto.git", .upToNextMajor(from: "3.0.0")),

        /// 💻 APIs for creating interactive CLI tools.
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0"),

        // DungeonChat shared code
        .package(url: "git@github.com:vyacheslavvorona/DungeonChatCore.git", from: "1.0.0")
//        .package(url: "../DungeonChatCore", from: "1.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: [
            "FluentSQLite",
            "Vapor",
            "Authentication",
            "Crypto",
            "Random",
            "Console",
            "DungeonChatCore"
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
