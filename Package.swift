// swift-tools-version: 5.7

import PackageDescription
import Foundation

let package = Package(
  name: "psychrometrics-cli",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .library(name: "CLIClient", targets: ["CLIClient"]),
    .library(name: "CLIClientLive", targets: ["CLIClientLive"]),
    .executable(name: "psychrometrics", targets: ["psychrometrics-cli"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-argument-parser.git",
      from: "1.2.3"
    ),
    .package(
      url: "https://github.com/swift-psychrometrics/swift-psychrometrics.git",
      from: "0.2.1"
    ),
    .package(
      url: "https://github.com/m-housh/swift-cli-version.git",
      from: "0.1.0"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies.git",
      from: "1.0.0"
    ),
    .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.0"),
  ],
  targets: [
    .target(
      name: "CLIClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SharedModels", package: "swift-psychrometrics")
      ]
    ),
    .target(
      name: "CLIClientLive",
      dependencies: [
        "CLIClient",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "PsychrometricClient", package: "swift-psychrometrics"),
        .product(name: "Rainbow", package: "Rainbow")
      ]
    ),
    .executableTarget(
      name: "psychrometrics-cli",
      dependencies: [
        "CLIClientLive",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "PsychrometricClientLive", package: "swift-psychrometrics")
      ]
    ),
    .testTarget(
      name: "psychrometrics-cliTests",
      dependencies: [
        "psychrometrics-cli"
      ]
    ),
  ]
)
