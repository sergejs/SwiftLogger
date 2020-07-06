// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftLogger",
  platforms: [
    .macOS(.v10_12),
    .iOS(.v10),
    .watchOS(.v3),
    .tvOS(.v10),
  ],
  products: [
    .library(
      name: "SwiftLogger",
      type: .dynamic,
      targets: ["SwiftLogger"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(name: "SwiftLogger", dependencies: []),
    .testTarget(name: "SwiftLoggerTests", dependencies: ["SwiftLogger"]),
  ]
)
