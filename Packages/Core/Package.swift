// swift-tools-version: 5.9
// Core — pure logic shared by the app and both extensions.
// Foundation only, so it runs under `swift test` on macOS.
// Filled in Session 1 (Zone, TargetMath, PeriodMath, DurationFormat,
// Checkpoint, SettingsKeys). This placeholder keeps the package buildable
// from Session 0.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "Core", targets: ["Core"])
    ],
    targets: [
        .target(name: "Core"),
        .testTarget(name: "CoreTests", dependencies: ["Core"])
    ]
)
