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
* TBD

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
to help with understanding of the different layers and trying to separation of concerns.

```swift
// LAYER 7: APPLICATION - High-level APIs, e.g. DTOs: `Payment`, `ChatMessage`, `TokenBalances`
protocol RadixApplicationClient {
	
	var nodeInteractor: NodeInteraction { get }
	
    func getBalances(for address: Address) -> Observable<BalancePerToken>
	func makeTransaction(_ transaction: Transaction) -> Completable
	func sendChatMessage(_ message: ChatMessage) -> Completable
}

// LAYER 6: LEDGER (Submit & Subscribe atoms)
protocol NodeInteraction {

	var connectedToNode: NodeConnection { get }

	func subscribe(to address: Address) -> Observable<AtomUpdate>
	func submit(atom: Atom) -> Observable<AtomUpdate>
	func unsubscribe(from address: Address) -> Completable
	func unsubscribeAll() -> Completable
}

// LAYER 5: NODE CONNECTION - Universe, Node
protocol NodeConnection {
	var node: Node { get }
	var rpcClient: RPCClient { get }
	var restClient: RESTClient { get }
}

// LAYER 4: NETWORK (Rpc, Http, WS)
// Sublayer B TRANSPORT (RPC, REST)

protocol RPCClient {

	var channel: FullDuplexCommunicationChannel { get }  

	func getInfo() -> Single<NodeRunnerData>
	func getLivePeers() -> Single<[NodeRunnerData]>
	func getUniverseConfig() -> Single<UniverseConfig>
	func getAtoms(query: AtomQuery) -> Observable<AtomSubscript>
	func submitAtom(_ atom: Atom) -> Observable<NodeAtomSubmissionUpdate>
}

protocol RESTClient {

	var httpClient: HTTPClient { get }

	func getLivePeers() -> Single<[NodeRunnerData]>
	func getUniverseConfig() -> Single<UniverseConfig>
}

// Sublayer A NETWORK (Websocket, HTTP)
protocol FullDuplexCommunicationChannel {

	func sendMessage(_ message: String)
	var messages: Observable<String> { get }
}

protocol HTTPClient {
	func request<Response>(router: Router) -> Observable<Response>
}

protocol Router {
	var path: URL
	var method: HTTPMethod
}

// LAYER 3: CHEMISTRY (Atom builders & reducers)
protocol TokenBalanceReducer {
	func reduce(atoms: Observable<AtomObservation>) -> Observable<TokenBalances>
}

protocol PaymentBuilder {
	func pay(address: Address, amount: Amount, of token: Token, signedBy signer: Signer) -> SignedAtomWithProofOfWork
}

// LAYER 2: ATOM MODEL - Particles
struct Atom {
	let particleGroups: [ParticleGroup]
}
struct ParticleGroup {
	let anySpunParticles: [AnySpunParticles]
}
struct AnySpunParticles {
	let spin: Spin
	let particle: Particle // TokenDefinitionParticle, UnallocatedTokensParticle, TransferrableTokens, MessageParticle etc..
}
enum Spin {
	case up, down
}

// LAYER 1: SUBATOMIC - Primitive DTOs (e.g. HexString, Amount, Nonce)
struct HexString {}
struct Base58String {}
struct Base64String {}
struct Amount {}
struct Nonce {}
```

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
