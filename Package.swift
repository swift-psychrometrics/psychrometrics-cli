// swift-tools-version: 5.7

import PackageDescription

let package = Package(
  name: "psychrometrics-cli",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .executable(name: "builder", targets: ["builder"]),
    .library(name: "CLIDependency", targets: ["CLIDependency"]),
    .library(name: "FileClient", targets: ["FileClient"]),
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
      url: "https://github.com/m-housh/swift-shell-client.git",
      from: "0.1.3"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies.git",
      from: "1.0.0"
    ),
  ],
  targets: [
    .executableTarget(
      name: "builder",
      dependencies: [
        "FileClient",
        .product(name: "ShellClient", package: "swift-shell-client"),
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      plugins: [
        .plugin(name: "BuildWithVersionPlugin", package: "swift-cli-version")
      ]
    ),
    .target(
      name: "CLIDependency",
      dependencies: [
        .product(name: "PsychrometricClient", package: "swift-psychrometrics")
      ]
    ),
    .target(
      name: "FileClient",
      dependencies: [
        .product(name: "ShellClient", package: "swift-shell-client"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .executableTarget(
      name: "psychrometrics-cli",
      dependencies: [
        "CLIDependency",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "PsychrometricClientLive", package: "swift-psychrometrics")
      ],
      plugins: [
        .plugin(name: "BuildWithVersionPlugin", package: "swift-cli-version")
      ]
    ),
    .testTarget(
      name: "psychrometrics-cliTests",
      dependencies: ["psychrometrics-cli"]
    ),
  ]
)
