# Radix Swift Library

[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**radixdlt-swift** is a Swift Client library for interacting with a [Radix](https://www.radixdlt.com) Distributed Ledger, written in ***Swift 5.1***.

### ❗️ Xcode 11 is required, since Swift 5.1 syntax and features are used.

## Table of contents

- [Changelog](CHANGELOG.md)
- [Features](#features)
- [Getting started](#getting-started)
- [Architecture](#architecture)
- [Design choices](#design-choices)
- [Dependencies](#dependencies)
- [Contribute](#contribute)
- [Links](#links)
- [License](#license)

## Features

### Radix Application

The `RadixApplicationClient` is the API layer this library exposes to you as a client developer. It allows you to create & transfer tokens, fetch balances and send messages.

```swift
final class RadixApplicationClient:
    AccountBalancing,
    TokenTransferring,
    TokenCreating,
    TokenMinting,
    TokenBurning,
    MessageSending // ...
{ ... }


protocol AccountBalancing {

    func observeBalances(ownedBy owner: ) -> AnyPublisher<TokenBalances, TokenBalancesReducerError>
    
    func observeBalance(
        ofToken tokenIdentifier: ResourceIdentifier,
        ownedBy owner: Address
    ) -> AnyPublisher<TokenBalance?, TokenBalancesReducerError>
    
}

protocol TokenTransferring {

    /// Transfers tokens to some address
    func transferTokens(action: TransferTokensAction) -> PendingTransaction

    func observeTokenTransfers(toOrFrom address: Address) -> AnyPublisher<TransferTokensAction, AtomToTransactionMapperError>
}

protocol TokenCreating {
    
    /// Creates a new kind of Token
    func createToken(action: CreateTokenAction) -> PendingTransaction
    
    func observeMyTokenDefinitions() -> AnyPublisher<TokenDefinitionsState, StateSubscriberError>
}


protocol TokenMinting {
    
    /// Mints new tokens of the TokenDefinition kind
    func mintTokens(action mintTokensAction: MintTokensAction) -> PendingTransaction
}

protocol TokenBurning {
    
    /// Burns tokens of the TokenDefinition kind
    func burnTokens(action burnTokensAction: BurnTokensAction) -> PendingTransaction
}

protocol MessageSending {
    
    func sendMessage(action sendMessageAction: SendMessageAction) -> PendingTransaction

    func observeMessages(toOrFrom address: Address) -> AnyPublisher<SendMessageAction, AtomToTransactionMapperError>
}

```

### Usage

Here are some example usages. The code below is an excerpt of an existing the integration (unit) test `TransferTokensTests.swift`.

#### Create Token

```swift
let aliceIdentity = AbstractIdentity()

let application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostTwoNodes, identity: aliceIdentity)

/// A Radix `Address` is dependent on `RadixUniverse` of the `RadixApplicationClient`. Betanet, Alphanet, Mainnet are examples of different Universes.
let alice: Address = application.addressOfActiveAccount

/// Alice defines her own token, resulting in a tuple, where first parameter is the pending result of the action,
/// the second is the Radix Resource Identifier (RRI) of the newly created token. The RRI uniquely identifies Alice's coin
/// having this format:  "/<ALICE_ADDRESS>/AC", "AC" matching the `symbol`
let (tokenCreation, rriAliceCoin) = application.createToken(name: "Alice Coin", symbol: "AC", description: "Best coin", supply: .fixed(to: 30))

try waitForTransactionToFinish(tokenCreation)

let aliceCoinTokenDefinition = try waitForFirstValue(of: applicationClient.observeTokenDefinition(identifier: rriAliceCoin))
XCTAssertEqual(aliceCoinTokenDefinition.symbol, "AC")


```

#### Get token balance

```swift
var alicesBalanceOfHerCoin = try waitForFirstValueUnwrapped(
    of: applicationClient.observeMyBalance(ofToken: rriAliceCoin)
)

XCTAssertEqual(alicesBalanceOfHerCoin.amount, 30)

let bob = applicationClient.addressOf(account: Account())
var bobsBalanceOfAliceCoin = try waitForFirstValueUnwrapped(
    of: applicationClient.observeBalance(ofToken: rriAliceCoin, ownedBy: bob)
)
```

#### Transfer tokens

```swift
// Alice sends 10 coins to Bob
let transfer = applicationClient.transferTokens(identifier: rri, to: bob, amount: 10, message: "For taxi fare")

try waitForTransactionToFinish(transfer)

alicesBalanceOfHerCoin = try waitForFirstValueUnwrapped(
    of: applicationClient.observeMyBalance(ofToken: rriAliceCoin)
)
XCTAssertEqual(alicesBalanceOfHerCoin.amount, 20) // 30 - 10 => 20

bobsBalanceOfAliceCoin = try waitForFirstValueUnwrapped(
    of: applicationClient.observeBalance(ofToken: rriAliceCoin, ownedBy: bob)
)

XCTAssertEqual(bobsBalanceOfAliceCoin.amount, 10) 
```

#### Send Message
```swift
// `application` is initialized above using Alice's identity
var pendingTransaction = application.sendEncryptedMessage("Hi Bob, this is a secret message from Alice", to: bob)
try waitForTransactionToFinish(pendingTransaction)


// Plain text messages (i.e. no encryption) can be sent like so
pendingTransaction = application.sendPlainTextMessage("Hi Bob (and the world) from Alice", to: bob)
try waitForTransactionToFinish(pendingTransaction)

// You can even include some third parties to be able to read the encrypted message
let carol: Address = application.addressOf(account: Account()) 
let diana: Address = application.addressOf(account: Account()) 


pendingTransaction = applicationClient.sendEncryptedMessage(
    "Hey Bob! Carol and Diana can also decrypt this encrypted message",
    to: bob,
    canAlsoBeDecryptedBy: [carol, diana]
)
```

## Getting started

### 0. Install Xcode 11

Install it from the [App Store](https://itunes.apple.com/gb/app/xcode/id497799835?mt=12).

**Make sure that you have a simulator installed**, by starting Xcode - agree to Terms and Conditions and install any additional dependency if needed - navigate to *Settings -> Components* and verify that you see at least one installed *iPhone Simulator* in the list.

#### Xcode Settings

Enabling parallel builds (if your computer has lots of RAM)
```bash
defaults write com.apple.dt.Xcode BuildSystemScheduleInherentlyParallelCommandsExclusively -bool NO
```

Showing build times in order to reduce it by focusing on complex code
```bash
defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
```

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

| LEVEL | NAME                                    		| FUNCTION                                                                	| COMPONENTS                                                             
|-------|-----------------------------------------------|---------------------------------------------------------------------------|------------------------------------------------------------------------
| 7     | [Application](#layer-7---application)   		| Transfer & create token, account balance 									| `RadixApplicationClient`, `AbstractIdentity`                         		 
| 6     | [Ledger](#layer-6---ledger)             		| Fetching and storing of Atoms                 							| `AtomStore`, `AtomObservation`                                   
| 5     | [Universe](#layer-5---universe)               | RadixUniverse, RadixNetwork, RadixNode and interaction with the nodes     | `Node`, `Universe`, `RadixNetwork`, `NodeAction`
| 4     | [Networking](#layer-4---networking)           | Networking (WebAocket, HTTP) and transport (RPC, REST)                   	| `RPCClient`, `RESTClient`, `WebsocketToNode`                           
| 3     | [Chemistry](#layer-3---chemistry)       		| Mapping user action to atoms and reducing atoms to state (e.g. balance) 	| `UserAction`, `ActionToParticlesMapper`, `AtomToExecutedActionReducer` 
| 2     | [Atom Model](#layer-2---atom-model)     		| Radix multi-purpose "transaction" packaged in the `Atom`.               	| `Atom`, `ParticleGroup`, `Spin` and particles                          
| 1     | [Subatomic](#layer-1---subatomic)     		| (De- &) serialization, crypto and models.                               	|  `DSONEncodable`, ECC, `HexString`, `Amount` etc...                    

#### Layer 7 - Application
High level application API for creating tokens, transferring tokens and fetching account balance, and more.

#### Layer 6 - Ledger
Fetching and storing atoms

#### Layer 5 - Universe
Connect to a Node and access its RPC and REST API's, please see the [API docs here](https://docs.radixdlt.com/node-api/) for a list of existing API's/

#### Layer 4 - Networking
Networking (WebSocket, HTTP) and transport (RPC, REST).

#### Layer 3 - Chemistry
Mapping user actions to particles used to instantiate Atoms. Reduce atoms into state, such as account balance.

#### Layer 2 - Atom Model
The Atom Model, consisting of `ParticleGroup`'s, which in turn consists of `Particle`'s. Read about the [Atom model here](https://docs.radixdlt.com/alpha/learn/architecture/atom-structure).

#### Layer 1 - Subatomic
Serialization and deserialization, cryptography and subatomic parts, making up the particles and also other low level DTO's such as `HexString`, `Base58String`.

## Design choices

### Why Carthage?
As of 2019-01-14, [BitcoinKit doesn't build using SPM](https://github.com/yenom/BitcoinKit/issues/224). But it works fine using Carthage.

### Why Combine based APIs?
First of all, all the existing Radix Libraries are FRP (Functional reactive programming, e.g. RxJava) based, secondly because it makes perfect sense since it makes async programming easy.

## Dependencies

You will find the dependencies in the [Cartfile](Cartfile).


## Other Radix Libraries
* [Java Library](https://github.com/radixdlt/radixdlt-java)
* [JavaScript Library](https://github.com/radixdlt/radixdlt-js)

## Contribute

Contributions are welcome, we simply ask to:

* Fork the codebase
* Make changes
* Submit a pull request for review

When contributing to this repository, we recommend discussing with the development team the change you wish to make using a [GitHub issue](https://github.com/radixdlt/radixdlt-swift/issues) before making changes.

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
