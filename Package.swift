// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "random-generator", targets: ["RandomGenerator"]),
        .executable(name: "speedster-hello", targets: ["SpeedsterHello"]),
        .library(name: "SpeedsterCore", targets: ["SpeedsterCore"]),
        .library(name: "VMWareRunKit", targets: ["VMWareRunKit"]),
        .library(name: "RefRepoKit", targets: ["RefRepoKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.3.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha.1.5"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-alpha.1.1"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-alpha.1.2"),
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
            name: "SpeedsterHello",
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
                "SpeedsterCore"
            ]
        ),
        .target(
            name: "GitHubKit",
            dependencies: [
                "Vapor"
            ]
        ),
        .target(
            name: "VMWareRestKit",
            dependencies: [
                "Vapor"
            ]
        ),
        .target(
            name: "VMWareRunKit",
            dependencies: [
                "ShellKit"
            ]
        ),
        .target(
            name: "ShellKit",
            dependencies: [
                "Shout",
                "SwiftShell",
                "NIO"
            ]
        ),
        .target(
            name: "RefRepoKit",
            dependencies: [
                "ShellKit"
            ]
        ),
        .target(
            name: "SpeedsterCore",
            dependencies: [
                "Fluent",
                "FluentPostgresDriver",
                "FluentSQLiteDriver",
                "Vapor",
                "GitHubKit",
                "CryptoKit",
                "Yams",
                "Jobs",
                "Redis",
                "JobsRedisDriver",
                "VMWareRestKit",
                "VMWareRunKit",
                "ShellKit",
                "RefRepoKit"
            ]
        ),
        .target(
            name: "Run",
            dependencies: ["App"]
        ),
        .testTarget(
            name: "SpeedsterCoreTests",
            dependencies: ["SpeedsterCore", "Yams"]
        ),
        .testTarget(
            name: "SpeedsterCoreRealTests",
            dependencies: ["SpeedsterCore"]
        ),
        .testTarget(
            name: "RefRepoKitTests",
            dependencies: ["RefRepoKit"]
        )
    ]
)

