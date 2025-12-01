// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReleaseKit",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "ReleaseKit",
            targets: ["ReleaseKit"]
        ),
    ],
    targets: [
        .target(
            name: "ReleaseKit",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ReleaseKitTests",
            dependencies: ["ReleaseKit"]
        ),
    ]
)
