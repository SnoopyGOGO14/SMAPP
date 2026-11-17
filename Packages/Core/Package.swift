// swift-tools-version: 5.7
// Core — pure logic shared by the app and both extensions.
// Foundation only, so it runs under `swift test` on the 2016 Intel
// build Mac (Swift 5.7.2, macOS 12). No Swift 5.9 features.
// The app targets in project.yml keep iOS 17.4; the package only sets
// the *minimum* it is willing to run on (iOS 16 / macOS 12).

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(name: "Core", targets: ["Core"])
    ],
    targets: [
        .target(name: "Core"),
        .testTarget(name: "CoreTests", dependencies: ["Core"])
    ]
)
