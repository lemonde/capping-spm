// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "capping-spm",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "LMDCapping",
            targets: ["LMDCapping"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "LMDCapping",
            url: "https://storage.googleapis.com/capping-sdk/capping-ios-sdk-1.3.zip",
            checksum: "f0df72993e07afd87fa23ea747c85ff12be09cf9ce0e9a0eea8e15326f86aafe"
        )
    ]
)
