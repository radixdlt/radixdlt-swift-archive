// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Before we can use SPM, this needs to be resolved: 
// https://stackoverflow.com/questions/58504112/package-swift-together-with-xcode-11-project-how-to-use-carthage-and-spm-alongs
// Relating to the BitcoinKit issue: https://github.com/yenom/BitcoinKit/issues/224

import PackageDescription

let package = Package(
    name: "RadixSDK",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "RadixSDK",
            targets: ["RadixSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.1.1"),

        .package(url: "https://github.com/attaswift/BigInt", from: "5.0.0"),

        // CBOR 
        // TODO: replace with `PotentCodables`? Might also remove lots of custom Serialization logic 
        // https://github.com/outfoxx/PotentCodables
        .package(url: "https://github.com/myfreeweb/SwiftCBOR", from: "0.4.3"),

        // TODO: Remove Alamofire, not so heavily used anyway
        .package(url: "https://github.com/Alamofire/Alamofire", .revision("c1d14588e5558a3669fd03510d135d88c5109069")),

        // TODO: Remove CryptoSwift in favour of Apples `CryptoKit` (new in iOS 13), read more:
        // https://developer.apple.com/documentation/cryptokit/sha256
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.1.2"),


        // TODO: Remove Starscream in favour of Apples `URLSessionWebSocketTask` (new in iOS 13), read more:
        // https://developer.apple.com/documentation/foundation/urlsessionwebsockettask
        .package(url: "https://github.com/daltoniam/Starscream", from: "3.1.1"),

        // TODO: Add BitcoinKit via SPM instead of Carthage (currently used), when proper SPM support is fixed
        // track this issue: https://github.com/yenom/BitcoinKit/issues/224
        // .package(url: "https://github.com/yenom/BitcoinKit", from: "1.1.0"),

        // ~~~===***{{{ TEST ONLY DEPENDENCIES }}}***===~~~
        .package(url: "https://github.com/birdrides/mockingbird", from: "0.7.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "RadixSDK iOS",
            dependencies: ["BigInt", "SwiftCBOR", "Alamofire", "CryptoSwift", "Starscream"],
            path: "Sources"
        ),
        .testTarget(
            name: "RadixSDK iOS Tests",
            dependencies: ["RadixSDK", "BigInt", "SwiftCBOR", "Alamofire", "CryptoSwift", "Starscream", "Mockingbird"],
            path: "Tests"
        ),
    ]
)