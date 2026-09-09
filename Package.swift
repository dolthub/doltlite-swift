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
            url: "https://github.com/dolthub/doltlite/releases/download/v0.50.8/doltlite-0.50.8.xcframework.zip",
            checksum: "b145c169ec9869cb59da916455d3f5fd2b975f78237c7d1bdaa21c635cee3766"
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
