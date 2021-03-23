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
      name: "Common",
      targets: ["Common"]
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
      .exact("6.1.0")
    )
  ],
  targets: [
    .target(
      name: "Common",
      dependencies: []
    ),
    .target(
      name: "CombineUNILib",
      dependencies: ["Common"]
    ),
    .target(
      name: "RxUNILib",
      dependencies: [
        "Common",
        "RxSwift",
        .product(name: "RxCocoa", package: "RxSwift")
      ]
    )
  ]
)
