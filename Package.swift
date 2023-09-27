// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KeyValueStorage",
    products: [
        .library(
            name: "KeyValueStorage",
            targets: [
                "KeyValueStorage",
                "ObservableKeyValueStorage"
            ]
        ),
    ],
    targets: [
        .target(
            name: "KeyValueStorage"
        ),
        .target(
            name: "ObservableKeyValueStorage",
            dependencies: ["KeyValueStorage"]
        ),
        .testTarget(
            name: "KeyValueStorageTests",
            dependencies: ["KeyValueStorage"]
        ),
        .testTarget(
            name: "ObservableKeyValueStorageTests",
            dependencies: ["ObservableKeyValueStorage"]
        ),
    ]
)
