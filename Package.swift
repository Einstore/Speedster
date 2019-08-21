// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Speedster",
    products: [
        .executable(name: "speedster", targets: ["App"]),
        .library(name: "SpeedsterCore", targets: ["SpeedsterCore"]),
        .library(name: "VMWareRunKit", targets: ["VMWareRunKit"]),
        .library(name: "RefRepoKit", targets: ["RefRepoKit"]),
        .library(name: "DockerCommandKit", targets: ["DockerCommandKit"])
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
        .package(url: "https://github.com/Einstore/GitHubKit.git", from: "1.0.0"),
        .package(url: "https://github.com/Einstore/SecretsKit.git", from: "1.0.0"),
        .package(url: "https://github.com/Einstore/ShellKit.git", from: "1.4.0"),
        .package(url: "https://github.com/Einstore/VaporErrorKit.git", from: "0.0.1"),
        .package(url: "https://github.com/Einstore/Systemator.git", from: "0.0.1"),
        .package(url: "https://github.com/rafiki270/Yams.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                "Fluent",
                "FluentPostgresDriver",
                "Vapor",
                "SpeedsterCore",
                "VaporErrorKit"
            ]
        ),
        .target(
            name: "K8Kit",
            dependencies: [
                "CommandKit"
            ]
        ),
        .target(
            name: "VMWareRunKit",
            dependencies: [
                "ShellKit"
            ]
        ),
        .target(
            name: "DockerCommandKit",
            dependencies: [
                "ShellKit"
            ]
        ),
        .target(
            name: "RefRepoKit",
            dependencies: [
                "CommandKit"
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
                "VMWareRunKit",
                "CommandKit",
                "RefRepoKit",
                "SecretsKit",
                "SystemController",
                "VaporErrorKit",
                "K8Kit"
            ]
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
            dependencies: ["RefRepoKit", "NIO", "CommandKit", "ExecutorMocks"]
        ),
        .testTarget(
            name: "VMWareRunKitTests",
            dependencies: ["VMWareRunKit", "NIO"]
        ),
        .testTarget(
            name: "DockerCommandKitTests",
            dependencies: ["DockerCommandKit"]
        )
    ]
)


