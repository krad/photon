// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "photon",
    products: [
        .library(
            name: "photon",
            targets: ["photon"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krad/workshop.git", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.3.1"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "1.0.0"),
        .package(url: "https://github.com/krad/grip.git", from: "1.3.4"),
    ],
    targets: [
        .target(
            name: "photon",
            dependencies: ["workshop", "NIO", "NIOOpenSSL", "grip"]),
        .testTarget(
            name: "photonTests",
            dependencies: ["photon"]),
    ]
)
