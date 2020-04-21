// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
    ],
    targets: [
        .target(
            name: "SwiftRenamer",
            dependencies: ["_CSwiftRenamer"]),
        .target(
            name: "_CSwiftRenamer",
            dependencies: []),
        .testTarget(
            name: "SwiftRenamerTests",
            dependencies: ["SwiftRenamer"])
    ]
)
