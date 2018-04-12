// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Curly",
    products: [
        .library(
            name: "Curly",
            targets: ["Curly"]),
    ],
    dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTP.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", from: "3.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "Curly",
            dependencies: [
                "PerfectHTTP",
                "PerfectCURL",
                "PerfectLogger"]),
        .testTarget(
            name: "CurlyTests",
            dependencies: ["Curly"]),
    ]
)
