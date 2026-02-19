// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TextHistoryBox",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "TextHistoryBox",
            path: "Sources/TextHistoryBox",
            linkerSettings: [
                .linkedFramework("Carbon"),
            ]
        ),
    ]
)
