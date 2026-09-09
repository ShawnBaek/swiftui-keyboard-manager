// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftUIKeyboardManager",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "SwiftUIKeyboardManager", targets: ["SwiftUIKeyboardManager"])],
    targets: [
        .target(name: "SwiftUIKeyboardManager"),
        .testTarget(name: "SwiftUIKeyboardManagerTests", dependencies: ["SwiftUIKeyboardManager"])
    ]
)
