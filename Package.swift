// swift-tools-version: 6.4
// Copyright 2026 Elliot Silver
// SPDX-License-Identifier: Apache-2.0

import PackageDescription

let package = Package(
    name: "Crumb",
    // SwiftPM has no Linux platform version. Ubuntu 22.04 and 24.04 build
    // with the same sources; only Apple platforms need a minimum here.
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Crumb",
            targets: ["Crumb"]
        ),
        .executable(
            name: "HelloCrumb",
            targets: ["HelloCrumb"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-nio.git",
            from: "2.105.0"
        ),
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.17.2"
        )
    ],
    targets: [
        .target(
            name: "Crumb",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .executableTarget(
            name: "HelloCrumb",
            dependencies: ["Crumb"],
            path: "Examples/HelloCrumb"
        ),
        .testTarget(
            name: "CrumbTests",
            dependencies: ["Crumb"]
        )
    ],
    swiftLanguageModes: [.v6]
)

