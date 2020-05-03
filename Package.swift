// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SwiftRenamer",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(
            name: "SwiftRenamer",
            targets: ["SwiftRenamer"])
    ],
    dependencies: [
        .package(name: "SwiftIndexStore", url: "https://github.com/kateinoigakukun/swift-indexstore", .branch("master")),
    ],
    targets: [
        .target(
            name: "SwiftRenamer",
            dependencies: [
                .product(name: "SwiftIndexStore", package: "SwiftIndexStore"),
            ]),
        .testTarget(
            name: "SwiftRenamerTests",
            dependencies: ["SwiftRenamer"])
    ]
)
