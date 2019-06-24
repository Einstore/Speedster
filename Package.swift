// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "random-generator", targets: ["RandomGenerator"]),
        .library(name: "SpeedsterCore", targets: ["SpeedsterCore"]),
        .library(name: "SpeedsterApi", targets: ["SpeedsterApi"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha.1.2"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-alpha.1.1"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-alpha.1"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-alpha.1"),
        .package(url: "https://github.com/vapor/crypto-kit.git", from: "4.0.0-alpha.1"),
        .package(url: "https://github.com/vapor/jobs.git", from: "1.0.0-alpha.1.1"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0-alpha.1"),
        .package(url: "https://github.com/vapor/jobs-redis-driver.git", from: "1.0.0-alpha.1.2"),
        //.package(url: "https://github.com/Einstore/GitHubKit.git", from: "1.0.0"),
        .package(url: "https://github.com/rafiki270/Yams.git", .branch("master")),
        .package(url: "https://github.com/jakeheis/Shout.git", from: "0.5.0"),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "RandomGenerator",
            dependencies: [
                "CryptoKit"
            ]
        ),
        .target(
            name: "App",
            dependencies: [
                "Fluent",
                "FluentPostgresDriver",
                "Vapor",
                "SpeedsterApi"
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
            name: "GitHubKit",
            dependencies: [
                "Vapor"
            ]
        ),
        .target(
            name: "SpeedsterApi",
            dependencies: [
                "Fluent",
                "FluentPostgresDriver",
                "FluentSQLiteDriver",
                "SpeedsterCore",
                "Vapor",
                "GitHubKit",
                "CryptoKit",
                "Yams",
                "Jobs",
                "Redis",
                "JobsRedisDriver"
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
