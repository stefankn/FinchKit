// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FinchKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "FinchKit",
            targets: ["FinchKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.4.3"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/stefankn/FinchProtocol.git", branch: "main")
    ],
    targets: [
        .target(
            name: "FinchKit",
            dependencies: [
                .product(name: "Factory", package: "Factory"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "FinchProtocol", package: "FinchProtocol")
            ]
        ),
        .testTarget(
            name: "FinchKitTests",
            dependencies: ["FinchKit"]
        ),
    ]
)
