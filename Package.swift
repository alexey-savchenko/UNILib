// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "UNILib",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(
      name: "UNILibCore",
      targets: ["UNILibCore"]
    )
  ],
  targets: [
    .target(
      name: "UNILibCore",
      dependencies: []
    )
  ]
)
