// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "tealium-cordova-firebase-plugin",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "tealium-cordova-firebase-plugin", targets: ["tealium-cordova-firebase-plugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/apache/cordova-ios.git", branch: "master"),
        .package(url: "https://github.com/tealium/tealium-swift.git", .upToNextMajor(from: "2.18.0")),
        .package(url: "https://github.com/tealium/tealium-ios-firebase-remote-command.git", .upToNextMajor(from: "3.2.0")),
        // cordova-ios 8+ always installs plugins as siblings under platforms/ios/packages/
        .package(name: "tealium-cordova-plugin", path: "../tealium-cordova-plugin")
    ],
    targets: [
        .target(
            name: "tealium-cordova-firebase-plugin",
            dependencies: [
                .product(name: "Cordova", package: "cordova-ios"),
                .product(name: "TealiumCore", package: "tealium-swift"),
                .product(name: "TealiumRemoteCommands", package: "tealium-swift"),
                .product(name: "TealiumFirebase", package: "tealium-ios-firebase-remote-command"),
                .product(name: "tealium-cordova-plugin", package: "tealium-cordova-plugin")
            ],
            path: "src/ios"
        )
    ]
)
