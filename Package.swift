// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SplashHaskell",
    products: [
        .library(
            name: "SplashHaskell",
            targets: ["SplashHaskell"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Splash", "0.13.0" ..< "0.14.0"),
    ],
    targets: [
        .target(
            name: "SplashHaskell",
            dependencies: ["Splash"]),
        .testTarget(
            name: "SplashHaskellTests",
            dependencies: ["SplashHaskell"]),
    ]
)
