// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SDKTest_CAS",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SDKTest_CAS",
            targets: ["SDKTest_CAS"]
        ),
    ],
//    dependencies: [
//        // We declare the dependency so the SDK code can compile (it needs to 'import CleverAdsSolutions').
//        // If the host app also uses SPM, SPM will deduplicate this.
//        // If the host app uses CocoaPods, you might have issues, but without this line, THIS package won't build.
//        .package(url: "https://github.com/cleveradssolutions/CAS-iOS.git", .upToNextMajor(from: "4.5.5"))
//    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SDKTest_CAS",
//            dependencies: [
//                .product(name: "CleverAdsSolutions", package: "CAS-iOS")
//            ]
        ),

    ]
)
