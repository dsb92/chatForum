// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "chatForum",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc"),
        // Authorization
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        // Firebase Cloud Messaging
        .package(url: "https://github.com/MihaelIsaev/FCM.git", from: "0.6.2"),
        .package(url: "https://github.com/vapor-community/pagination.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Authentication", "FCM", "Pagination"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
