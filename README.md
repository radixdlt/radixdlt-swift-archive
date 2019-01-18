# Radix Swift Library

**radixdlt-swift** is a Swift Client library for interacting with a [Radix](https://www.radixdlt.com) Distributed Ledger.

## Features
* TBD

# Getting Started

## Prerequisites
### 0. [Xcode 10](https://itunes.apple.com/gb/app/xcode/id497799835?mt=12)
**Make sure that you have a simulator installed**, by starting Xcode - agree to Terms and Conditions and install any additional dependency if needed - navigate to *Settings -> Components* and verify that you see at least one installed *iPhone Simulator* in the list.

### 1. `git clone git@github.com:radixdlt/radixdlt-swift.git && cd radixdlt-swift`
### 2. [brew](https://brew.sh/)
Use link above, but should be something like:
```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
### 3. [carthage](https://github.com/Carthage/Carthage)
```bash
brew install carthage
```

If that command says that Carthage needs **linking** (maybe it was already installed but not linked) with a permissions error similar to the one below:
```
Warning: carthage 0.31.2 is already installed, it's just not linked
You can use `brew link carthage` to link this version.
$ brew link carthage
Linking /usr/local/Cellar/carthage/0.31.2... Error: Permission denied @ dir_s_mkdir - /usr/local/Frameworks
```

Then you can fix that by running:
```
sudo mkdir -p /usr/local/Frameworks && \
sudo chown -R $(whoami) /usr/local/Frameworks && \
brew link carthage
```

Which makes sure that your current user is owning that directory, therefore `brew link` can **sudoless** - which is needed. For more info about this issue, [please refer to this Gist](https://gist.github.com/irazasyed/7732946).

### 4. [swiftlint](https://github.com/realm/SwiftLint) - `brew install swiftlint`
### 5. Install dependencies using Carthage
Please make sure that your **current directory is the _root of the repo_** (as per previous instructions).
```bash
carthage bootstrap --platform iOS --cache-builds
```

If that fails you might need to install some additional tools:
```bash
brew install autoconf automake libtool pkgconfig wget
````

Which suggests adding some exports in your shell profile, try:

```bash
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"
export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"
```

### 6. `open RadixSDK.xcodeproj`
### 7. Run unit tests: `CMD` + `U` to verify that everything is working. 

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