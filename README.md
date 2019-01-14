# Radix Swift Library

**radixdlt-swift** is a Swift Client library for interacting with a [Radix](https://www.radixdlt.com) Distributed Ledger.

## Features
* TBD

# Getting Started

## Prerequisites
0. Xcode
1. [brew](https://brew.sh/)
2. [carthage](https://github.com/Carthage/Carthage) - `brew install carthage`
3. [swiftlint](https://github.com/realm/SwiftLint) - `brew install swiftlint`
4. Install dependencies - `carthage bootstrap --cache-builds`
5. `open RadixSDK.xcodeproj`

# Dependencies

You will find the dependencies in the [Cartfile](Cartfile), but we will go through the most important ones here:

## [BitcoinKit](https://github.com/yenom/BitcoinKit)
Elliptic Curve Cryptography, this library is one of the better Swift wrappers of the C library [bitcoin-core/secp256k1](https://github.com/bitcoin-core/secp256k1).

## [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)
For standard crypto utilities such as hash functions.

## [BigInt](https://github.com/attaswift/BigInt)
Support for big numbers.

## [RxSwift](https://github.com/ReactiveX/RxSwift)
The library uses RxSwift for async programming.

# Architecture

To be written.

## Design choices

### Why Carthage?
As of 2019-01-14, [BitcoinKit doesn't build using Cocoapods](https://github.com/yenom/BitcoinKit/issues/193). But it works fine using Carthage.

### Why RxSwift based APIs?
First of all, all the existing Radix Libraries are Rx based, secondly because it makes perfect sense since it makes async programming easy.

# Other Radix Libraries
* [Java Library](https://github.com/radixdlt/radixdlt-java)
* [JavaScript Library](https://github.com/radixdlt/radixdlt-js)