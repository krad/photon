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
	.package(url: "https://github.com/IBM-Swift/BlueSocket.git", from: "0.12.77"),
	.package(url: "https://github.com/krad/workshop.git", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.3.1"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "photon",
            dependencies: ["Socket", "workshop", "NIO", "NIOOpenSSL"]),
        .testTarget(
            name: "photonTests",
            dependencies: ["photon"]),
    ]
)
