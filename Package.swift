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
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.4.3")
    ],
    targets: [
        .target(
            name: "FinchKit",
            dependencies: ["Factory"]
        ),
        .testTarget(
            name: "FinchKitTests",
            dependencies: ["FinchKit"]
        ),
    ]
)
