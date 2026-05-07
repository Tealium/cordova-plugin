// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "tealium-cordova-plugin",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "tealium-cordova-plugin", targets: ["tealium-cordova-plugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/apache/cordova-ios.git", branch: "master"),
        .package(url: "https://github.com/tealium/tealium-swift.git", .upToNextMajor(from: "2.18.0"))
    ],
    targets: [
        .target(
            name: "tealium-cordova-plugin",
            dependencies: [
                .product(name: "Cordova", package: "cordova-ios"),
                .product(name: "TealiumCore", package: "tealium-swift"),
                .product(name: "TealiumCollect", package: "tealium-swift"),
                .product(name: "TealiumTagManagement", package: "tealium-swift"),
                .product(name: "TealiumLifecycle", package: "tealium-swift"),
                .product(name: "TealiumRemoteCommands", package: "tealium-swift"),
                .product(name: "TealiumVisitorService", package: "tealium-swift")
            ],
            path: "src/ios"
        )
    ]
)
