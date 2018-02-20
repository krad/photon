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
    ],
    targets: [
        .target(
            name: "photon",
            dependencies: ["Socket"]),
        .testTarget(
            name: "photonTests",
            dependencies: ["photon"]),
    ]
)
