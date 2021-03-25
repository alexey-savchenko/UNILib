// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "UNILib",
  platforms: [
    .iOS(.v13),
    .macOS(SupportedPlatform.MacOSVersion.v10_15)
  ],
  products: [
    .library(
      name: "UNILibCore",
      targets: ["UNILibCore"]
    ),
    .library(
      name: "CombineUNILib",
      targets: ["CombineUNILib"]
    ),
    .library(
      name: "RxUNILib",
      targets: ["RxUNILib"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/ReactiveX/RxSwift.git",
      .exact("5.0.0")
    ),
    .package(
        name: "Reachability",
        url: "https://github.com/ashleymills/Reachability.swift",
        .upToNextMajor(from: "5.0.0")
    )
  ],
  targets: [
    .target(
      name: "UNILibCore",
      dependencies: []
    ),
    .target(
      name: "CombineUNILib",
      dependencies: ["UNILibCore"]
    ),
    .target(
      name: "RxUNILib",
      dependencies: [
        "UNILibCore",
        "RxSwift",
        "Reachability",
        .product(name: "RxCocoa", package: "RxSwift")
      ]
    )
  ]
)
