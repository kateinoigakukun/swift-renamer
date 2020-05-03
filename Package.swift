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
                .target(name: "_CSwiftRenamer"),
                .product(name: "SwiftIndexStore", package: "SwiftIndexStore"),
            ]),
        .target(
            name: "_CSwiftRenamer",
            dependencies: []),
        .testTarget(
            name: "SwiftRenamerTests",
            dependencies: ["SwiftRenamer"])
    ]
)
