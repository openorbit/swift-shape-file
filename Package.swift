// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-shapefile",
    platforms: [
        .macOS(.v15)
    ],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Shapefile",
            targets: ["Shapefile"]
        ),
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-binary-parsing.git", .upToNextMinor(from: "0.0.1")),
      .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Shapefile",
            dependencies: [
              .product(name: "BinaryParsing", package: "swift-binary-parsing"),
            ]
        ),

        .testTarget(
            name: "ShapefileTests",
            dependencies: [
              "Shapefile",
              .product(name: "Numerics", package: "swift-numerics"),
            ],
            resources: [
                .copy("TestData"),
            ],
        ),
    ]
)
