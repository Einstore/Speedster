// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .library(name: "SpeedsterCore", targets: ["SpeedsterCore"]),
        .library(name: "SpeedsterApi", targets: ["SpeedsterApi"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha.1.2"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-alpha.1.1"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-alpha.1"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-alpha.1"),
        //.package(url: "https://github.com/Einstore/GithubAPI.git", from: "1.0.0"),
        .package(url: "https://github.com/jakeheis/Shout.git", from: "0.5.0"),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.0.0")
    ],
    targets: [
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
            name: "GithubAPI",
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
                "GithubAPI"
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

