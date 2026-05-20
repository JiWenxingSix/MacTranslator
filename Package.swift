// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MacTranslator",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MacTranslator", targets: ["MacTranslator"])
    ],
    targets: [
        .executableTarget(
            name: "MacTranslator",
            path: "Sources/MacTranslator"
        )
    ]
)
