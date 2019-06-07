// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-alpha"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-alpha"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-alpha"),
        .package(url: "https://github.com/jakeheis/Shout.git", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                "Fluent",
                "FluentPostgresDriver",
                "Vapor",
                "SpeedsterCore"
            ]
        ),
        .target(
            name: "SpeedsterCore",
            dependencies: [
                "Fluent",
                "FluentPostgresDriver",
                "FluentSQLiteDriver",
                "Vapor",
                "Shout"
            ]
        ),
        .target(
            name: "Run",
            dependencies: ["App"]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: ["App"]
        )
    ]
)

