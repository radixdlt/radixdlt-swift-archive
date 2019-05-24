# Radix Swift Library

[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**radixdlt-swift** is a Swift Client library for interacting with a [Radix](https://www.radixdlt.com) Distributed Ledger.

## Table of contents

- [Features](#features)
- [Getting started](#getting-started)
- [Architecture](#architecture)
- [Design choices](#design-choices)
- [Dependencies](#dependencies)
- [Contribute](#contribute)
- [Links](#links)
- [License](#license)

## Features
⚠️👷🏾‍♀️ The Swift library is not production yet, its under construction 🚜⚠️  

This is a **sneak peak** of the **coming** Application Layer API

### Radix Application

The `RadixApplicationClient` is the API layer this library exposes to you as a client developer. It will allow you to create and transfer tokens and also to fetch balances for a certain Radix address.

```swift
typealias RadixApplicationClient = Transacting & AccountBalancing & TokenCreating

protocol TokenCreating {
    func create(token: CreateTokenAction) -> Single<ResourceIdentifier>
}

protocol Transacting {
    func transfer(tokens: TransferTokenAction) -> Completable
}

protocol AccountBalancing {
    func getBalances(for address: Address) -> Observable<AccountBalances>
    func getBalances(for address: Address, ofToken token: ResourceIdentifier) -> Observable<AccountBalanceOf>
}
```

### Usage

Here are some example usages. The code below is an excerpt of an existing the unit test [`TransferTokensTests.swift`](https://github.com/radixdlt/radixdlt-swift/blob/master/Tests/TestCases/Radix/0.%20Layer%207%20-%20APPLICATION%20(Transactions%2C%20Balances)/TransferTokensTests.swift)

(In the Swift code below, for the sake of readability, we have written out the result as if the API's were synchronous. As you saw in above these methods they are asynchronous returning `Observables`, so we have omitted the appropriate [`toBlocking`](https://github.com/ReactiveX/RxSwift/blob/master/RxBlocking/ObservableConvertibleType+Blocking.swift) call.)

#### Create Token

```swift
let alice = RadixIdentity()

// Instantiate a RadixApplicationClient connecting to a `localhost` in this example, with Alice identity
let application = DefaultRadixApplicationClient(node: .localhost, identity: alice)

// Alice defines her own token
let createToken = CreateTokenAction(
    creator: alice.address,
    name: "Alice Coin",
    symbol: "AC",
    description: "Best coin",
    supplyType: .fixed,
    initialSupply: 30
)

// Alice creates a new token with an initial supply of 30
application.create(token: createToken)
```

#### Get token balance

```swift
let bob = RadixIdentity()

var alicesBalanceOfHerCoin = application.getMyBalance(of: rri)
var bobsBalanceOfAliceCoin = application.getBalances(for: bob.address, ofToken: rri)

assert(alicesBalanceOfHerCoin.balance == 30, "Alice's balance should equal `30`(initialSupply)")
assert(bobsBalanceOfAliceCoin.balance == 0, "Bob's balance should equal `0`")
```

#### Transfer tokens

```swift
// Alice sends 10 coins to Bob
let transfer = TransferTokenAction(from: alice, to: bob, amount: 10, tokenResourceIdentifier: rri)

application.transfer(tokens: transfer).take(1)

alicesBalanceOfHerCoin = application.getMyBalance(of: rri)
bobsBalanceOfAliceCoin = application.getBalances(for: bob.address, ofToken: rri)

assert(alicesBalanceOfHerCoin.balance == 20, "Alice's balance should equal `20`")
assert(bobsBalanceOfAliceCoin.balance == 10, "Bob's balance should equal `10`")

```

## Getting started

### 0. Install Xcode 10.2

Install it from the [App Store](https://itunes.apple.com/gb/app/xcode/id497799835?mt=12).

**Make sure that you have a simulator installed**, by starting Xcode - agree to Terms and Conditions and install any additional dependency if needed - navigate to *Settings -> Components* and verify that you see at least one installed *iPhone Simulator* in the list.

### 1. Clone this repo
```bash
git clone git@github.com:radixdlt/radixdlt-swift.git && cd radixdlt-swift
```

### 2. Install `brew`
```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

#### Issues?
[See brew troubleshooting page](https://docs.brew.sh/Troubleshooting)

### 3. Install `carthage`
```bash
brew install carthage
```

**Make sure that you have version 0.32 or later installed, otherwise it will not work with Xcode 10.2**

#### Issues?
If that command says that Carthage needs **linking** (maybe it was already installed but not linked) with a permissions error similar to the one below:
```bash
Warning: carthage 0.32 is already installed, it's just not linked
You can use `brew link carthage` to link this version.
$ brew link carthage
Linking /usr/local/Cellar/carthage/0.32... Error: Permission denied @ dir_s_mkdir - /usr/local/Frameworks
```

Then you can fix that by running:
```bash
sudo mkdir -p /usr/local/Frameworks && \
sudo chown -R $(whoami) /usr/local/Frameworks && \
brew link carthage
```

Which makes sure that your current user is owning that directory, therefore `brew link` can **sudoless** - which is needed. For more info about this issue, [please refer to this Gist](https://gist.github.com/irazasyed/7732946).

### 4. Install `swiftlint`
```bash
brew install swiftlint
```

#### Issues?
If you have any issues [go to swiftlint repo](https://github.com/realm/SwiftLint)


### 5. Install dependencies using Carthage
Please make sure that your **current directory is the _root of the repo_** (as per previous instructions).
```bash
carthage bootstrap --platform iOS --cache-builds
```

#### Issues?
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

### 6. Run tests
Open the project:
```bash
open RadixSDK.xcodeproj
```

In Xcode run the tests by pressing `CMD` + `U`, verify that everything is working. 

## Architecture

### Stack
Some rough, inaccurate attempt to map components within this library to the [OSI Model](https://en.wikipedia.org/wiki/OSI_model)
to help with understanding of the different layers and trying to ease separation of concern.

| LEVEL | NAME                                         | FUNCTION                                                                   | COMPONENTS                                                        |
|-------|----------------------------------------------|----------------------------------------------------------------------------|-------------------------------------------------------------------|
| 7     | [Application](#layer-7--application)         | Transfer & create token, account balance | `ApplicationClient`, `RadixIdentity`                         |
| 6     | [Ledger](#layer-6--ledger)                   | Subscribing to and submission of atoms          | `NodeInteraction`, `AtomUpdate`                                   |
| 5     | [Node Con.](#layer-5--node-connection) | Connection to a node's RPC and REST API's                                  | `Node`, `NodeConnection`, `Universe`                         |
| 4     | [Network](#layer-4--network)                 | Network (Websocket, HTTP) and transport (RPC, REST)                   | `RPCClient`, `RESTClient`, `WebsocketToNode                       |
| 3     | [Chemistry](#layer-3--chemistry)             | Mapping user action to atoms and reducing atoms to state (e.g. balance)    | `CreateTokenAction`, `TransferTokenAction`, `TokenBalanceReducer` |
| 2     | [Atom Model](#layer-2--atom-model)           | Radix multi-purpose "transaction" packaged in the `Atom`.                  | `Atom`, `ParticleGroup`, `Spin` and particles                     |
| 1     | [Subatomic]((#layer-1--subatomic))           | (De- &) serialization, crypto and models.                                  |  `DSONEncodable`, ECC, `HexString`, `Amount` etc...               |

#### Layer 7 - Application
High level application API for creating tokens, transferring tokens and fetching account balance, and more.

#### Layer 6 - Ledger
Subscribe to atoms for a certain Radix address and submit new atoms to the ledger.

#### Layer 5 - Node Connection
Connect to a Node and access its RPC and REST API's, please see the [API docs here](https://docs.radixdlt.com/node-api/) for a list of existing API's/

#### Layer 4 - Network
Networking (Websocket, HTTP) and transport (RPC, REST).

#### Layer 3 - Chemistry
Mapping user actions to particles used to instantiate Atoms. Reduce atoms into state, such as account balance.

#### Layer 2 - Atom Model
The Atom Model, consisting of `ParticleGroup`'s, which in turn consists of `Particle`'s. Read about the [Atom model here](https://docs.radixdlt.com/alpha/learn/architecture/atom-structure).

#### Layer 1 - Subatomic
Serialization and deserialization, cryptography and subatomic parts, making up the particles and also other low level DTO's such as `HexString`, `Base58String`.

## Design choices

### Why Carthage?
As of 2019-01-14, [BitcoinKit doesn't build using Cocoapods](https://github.com/yenom/BitcoinKit/issues/193). But it works fine using Carthage.

### Why RxSwift based APIs?
First of all, all the existing Radix Libraries are Rx based, secondly because it makes perfect sense since it makes async programming easy.

## Dependencies

You will find the dependencies in the [Cartfile](Cartfile), but we will go through the most important ones here:

- [BitcoinKit](https://github.com/yenom/BitcoinKit):
Elliptic Curve Cryptography, this library is one of the better Swift wrappers of the C library [bitcoin-core/secp256k1](https://github.com/bitcoin-core/secp256k1).

- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift):
For standard crypto utilities such as hash functions.

- [BigInt](https://github.com/attaswift/BigInt):
Support for big numbers.

- [RxSwift](https://github.com/ReactiveX/RxSwift):
The library uses RxSwift for async programming.


## Other Radix Libraries
* [Java Library](https://github.com/radixdlt/radixdlt-java)
* [JavaScript Library](https://github.com/radixdlt/radixdlt-js)

## Contribute

Contributions are welcome, we simply ask to:

* Fork the codebase
* Make changes
* Submit a pull request for review

When contributing to this repository, we recommend to discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change. 

Please follow our [Code of Conduct](CODE_OF_CONDUCT.md) in all your interactions with the project.

## Links

| Link | Description |
| :----- | :------ |
[radixdlt.com](https://radixdlt.com/) | Radix DLT Homepage
[documentation](https://docs.radixdlt.com/) | Radix Knowledge Base
[forum](https://forum.radixdlt.com/) | Radix Technical Forum
[@radixdlt](https://twitter.com/radixdlt) | Follow Radix DLT on Twitter

## License

The **radixdlt-swift** library is released under the [MIT License](LICENSE).
