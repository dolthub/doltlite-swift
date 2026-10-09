// swift-tools-version:5.9
import PackageDescription

// DoltLite for Swift: SQLite with Dolt-style version control (branches,
// commits, merge, diff) as a prebuilt XCFramework for iOS, iOS Simulator,
// macOS, and Mac Catalyst.
//
// The binaryTarget url and checksum below are updated automatically on each
// release by the doltlite release workflow (dolthub/doltlite). The values on
// `main` are placeholders; resolve a tagged version (>= 0.11.17) to build.
let package = Package(
    name: "Doltlite",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .macCatalyst(.v14),
    ],
    products: [
        .library(name: "Doltlite", targets: ["Doltlite"]),
    ],
    targets: [
        .binaryTarget(
            name: "CDoltlite",
            url: "https://github.com/dolthub/doltlite/releases/download/v0.50.17/doltlite-0.50.17.xcframework.zip",
            checksum: "ca46cffe94164b6e239d61b7d3e1897af6582876ae6cdf809366cf5c4e0d954b"
        ),
        .target(
            name: "Doltlite",
            dependencies: ["CDoltlite"]
        ),
        .testTarget(
            name: "DoltliteTests",
            dependencies: ["Doltlite"]
        ),
    ]
)
