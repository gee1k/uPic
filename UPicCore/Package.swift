// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "UPicCore",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(
            name: "UPicCore",
            targets: ["UPicCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.9.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.2"),
        .package(url: "https://github.com/Miles-Matheson/HandyJSON.git", branch: "master"),
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "8.1.1"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.8.0")
    ],
    targets: [
        .target(
            name: "UPicCore",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "HandyJSON", package: "HandyJSON"),
                .product(name: "SWXMLHash", package: "SWXMLHash"),
                .product(name: "SotoS3", package: "soto")
            ]
        ),
        .testTarget(
            name: "UPicCoreTests",
            dependencies: ["UPicCore"]
        )
    ]
)
