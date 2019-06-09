// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "carthage-cache", targets: ["CarthageCache"]),
        .library(name: "SpeedsterCore", targets: ["SpeedsterCore"]),
        .library(name: "SpeedsterDB", targets: ["SpeedsterDB"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-alpha"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-alpha"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-alpha"),
        .package(url: "https://github.com/jakeheis/Shout.git", from: "0.5.0"),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "CarthageCache",
            dependencies: [
                "Vapor"
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                "Fluent",
                "FluentPostgresDriver",
                "Vapor",
                "SpeedsterDB"
            ]
        ),
        .target(
            name: "SpeedsterCore",
            dependencies: [
                "Vapor",
                "Shout",
                "SwiftShell"
            ]
        ),
        .target(
            name: "SpeedsterDB",
            dependencies: [
                "Fluent",
                "FluentPostgresDriver",
                "FluentSQLiteDriver",
                "SpeedsterCore",
                "Vapor"
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

