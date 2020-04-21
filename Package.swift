// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftRename",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(
            name: "SwiftRename",
            targets: ["SwiftRename"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftRename",
            dependencies: ["_CSwiftRename"]),
        .target(
            name: "_CSwiftRename",
            dependencies: []),
        .testTarget(
            name: "SwiftRenameTests",
            dependencies: ["SwiftRename"])
    ]
)
