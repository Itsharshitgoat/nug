// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Nuggs",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "Nuggs", targets: ["Nuggs"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Nuggs",
            dependencies: [],
            path: "Nuggs",
            resources: [
                .copy("Resources")
            ]
        ),
        .testTarget(
            name: "NuggsTests",
            dependencies: ["Nuggs"],
            path: "Tests/NuggsTests"
        )
    ]
)
