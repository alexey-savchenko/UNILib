// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "UNILib",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(
      name: "UNILib",
      targets: ["UNILib"]
    ),
    .library(
      name: "RxUNILib",
      targets: ["RxUNILib"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/ReactiveX/RxSwift.git",
      .exact("6.1.0")
    )
  ],
  targets: [
    .target(
      name: "UNILib",
      dependencies: []
    ),
    .target(
      name: "RxUNILib",
      dependencies: ["UNILib", "RxSwift"]
    ),
  ]
)
