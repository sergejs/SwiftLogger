// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftLogger",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .watchOS(.v6),
    .tvOS(.v13),
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
