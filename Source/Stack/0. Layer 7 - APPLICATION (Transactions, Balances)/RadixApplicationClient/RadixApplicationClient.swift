//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import Combine

// MARK: - RadixApplicationClient

// swiftlint:disable opening_brace colon

public final class RadixApplicationClient:
    AccountBalancing,
    TokenTransferring,
    TokenCreating,
    TokenMinting,
    TokenBurning,
    MessageSending,
    UniqueMaking,
    TransactionMaker,
    TransactionToAtomMapper,
    AtomToTransactionMapper,
    StateSubscriber,
    TransactionSubscriber,
    AddressOfAccountDeriving,
    ActiveAccountOwner,
    Magical
{
    // swiftlint:enable opening_brace colon
    
    // MARK: - Stored properties
    
    /// The chosen Radix universe, a network of nodes running a specific version of the Radix Node Runner software
    public let universe: RadixUniverse
    
    /// A holder of accounts belonging to the same person, with or without signing (`private`) keys.
    public private(set) var identity: AbstractIdentity
    
    /// Preparing and sending of Atoms to Radix Network
    private let transactionMaker: TransactionMaker
    
    /// A subscriber of state, derived from particles
    private let stateSubscriber: StateSubscriber
    
    /// A subscriber of executed transactions at a given address
    private let transactionSubscriber: TransactionSubscriber
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        identity: AbstractIdentity,
        universe: RadixUniverse,
        transactionMaker: TransactionMaker,
        stateSubscriber: StateSubscriber,
        transactionSubscriber: TransactionSubscriber
    ) {
        self.universe = universe
        self.identity = identity
        
        self.transactionMaker = transactionMaker
        self.stateSubscriber = stateSubscriber
        self.transactionSubscriber = transactionSubscriber
    }
}

// MARK: Convenience Init
public extension RadixApplicationClient {
    
    /// Initialises a RadixApplicationClient from a BootstrapConfig
    convenience init(bootstrapConfig: BootstrapConfig, identity: AbstractIdentity) {
        let universe = DefaultRadixUniverse(bootstrapConfig: bootstrapConfig)
        let atomStore = universe.atomStore
        let activeAccount = identity.activeAccountObservable
        
        let transactionMaker = DefaultTransactionMaker(
            activeAccount: activeAccount,
            universe: universe
        )
        
        let stateSubscriber = DefaultStateSubscriber(
            atomStore: atomStore
        )
        
        let transactionSubscriber = DefaultTransactionSubscriber(
            atomStore: atomStore,
            activeAccount: activeAccount
        )
        
        self.init(
            identity: identity,
            universe: universe,
            transactionMaker: transactionMaker,
            stateSubscriber: stateSubscriber,
            transactionSubscriber: transactionSubscriber
        )
    }
}

// MARK: TransactionMaker
public extension RadixApplicationClient {
    func send(transaction: Transaction, toOriginNode originNode: Node?) -> ResultOfUserAction {
        transactionMaker.send(transaction: transaction, toOriginNode: originNode)
    }
}

// MARK: TransactionToAtomMapper
public extension RadixApplicationClient {
    func atomFrom(transaction: Transaction, addressOfActiveAccount: Address) throws -> Atom {
        return try transactionMaker.atomFrom(transaction: transaction, addressOfActiveAccount: addressOfActiveAccount)
    }
}

// MARK: AtomToTransactionMapper
public extension RadixApplicationClient {
    func transactionFromAtom(_ atom: Atom) -> AnyPublisher<ExecutedTransaction, Never> {
        return transactionSubscriber.transactionFromAtom(atom)
    }
}

// MARK: TokenCreating
public extension RadixApplicationClient {
    func create(token createTokenAction: CreateTokenAction) -> ResultOfUserAction {
        return execute(actions: createTokenAction)
    }
    
    /// Returns a hot observable of the latest state of token definitions at the user's address
    func observeMyTokenDefinitions() -> AnyPublisher<TokenDefinitionsState, Never> {
        return observeTokenDefinitions(at: addressOfActiveAccount)
    }
}

// MARK: TokenMinting
public extension RadixApplicationClient {
    func mintTokens(_ action: MintTokensAction) -> ResultOfUserAction {
        return execute(actions: action)
    }
}

// MARK: TokenBurning
public extension RadixApplicationClient {
    func burnTokens(_ action: BurnTokensAction) -> ResultOfUserAction {
        return execute(actions: action)
    }
}

// MARK: TokenTransferring
public extension RadixApplicationClient {
    func transfer(tokens transferTokensAction: TransferTokensAction) -> ResultOfUserAction {
        return execute(actions: transferTokensAction)
    }
    
    func observeTokenTransfers(toOrFrom address: Address) -> AnyPublisher<TransferTokensAction, Never> {
        return observeActions(ofType: TransferTokensAction.self, at: address)
    }
}

// MARK: MessageSending
public extension RadixApplicationClient {
    func send(message sendMessageAction: SendMessageAction) -> ResultOfUserAction {
        return execute(actions: sendMessageAction)
    }
    
    func observeMessages(toOrFrom address: Address) -> AnyPublisher<SendMessageAction, Never> {
        return observeActions(ofType: SendMessageAction.self, at: address)
    }
}

// MARK: UniqueMaking
public extension RadixApplicationClient {
    func putUniqueId(_ putUniqueAction: PutUniqueIdAction) -> ResultOfUserAction {
        return execute(actions: putUniqueAction)
    }
}

// MARK: AccountBalancing
public struct TokenBalancesReducer {
    public typealias TokenBalancesOfAddress = (Address) -> AnyPublisher<TokenBalances, Never>
    public let tokenBalancesOfAddress: TokenBalancesOfAddress
    init(tokenBalancesOfAddress: @escaping TokenBalancesOfAddress) {
        self.tokenBalancesOfAddress = tokenBalancesOfAddress
    }
}

public extension TokenBalancesReducer {
    
    static func usingApplicationClient(_ app: RadixApplicationClient) -> Self {
        Self(
            makeBalanceReferencesStatePublisher: { [unowned app] in app.observeBalanceReferences(at: $0) },
            makeTokenDefinitionsPublisher: { [unowned app] in app.observeTokenDefinitions(at: $0) }
        )
    }
    
    init(
        makeBalanceReferencesStatePublisher: @escaping (Address) -> AnyPublisher<TokenBalanceReferencesState, Never>,
        makeTokenDefinitionsPublisher: @escaping (Address) -> AnyPublisher<TokenDefinitionsState, Never>
    ) {
        self.init { address in

            return makeBalanceReferencesStatePublisher(address)
                .flatMap { state -> AnyPublisher<TokenBalances, Never> in
                    Publishers.Sequence<[TokenReferenceBalance], Never>(sequence: state.tokenReferenceBalances)
                        .flatMap { tokenReferenceBalance -> AnyPublisher<TokenBalance, Never> in
                            makeTokenDefinitionsPublisher(tokenReferenceBalance.tokenResourceIdentifier.address)
                                .tryMap { tokenDefinitionState -> TokenBalance in
                                    
                                    guard
                                        case let rri = tokenReferenceBalance.tokenResourceIdentifier,
                                        let tokenDefinition = tokenDefinitionState.tokenDefinition(identifier: rri)
                                        else { incorrectImplementation("Expected token definition") }
                                    
                                    return try TokenBalance(tokenDefinition: tokenDefinition, tokenReferenceBalance: tokenReferenceBalance)
                            }
                            .crashOnFailure()
                    }
                    .collect(state.tokenReferenceBalances.count)
                    .eraseToAnyPublisher()
                    .map { (tokenBalances: [TokenBalance]) -> TokenBalances in
                        TokenBalances(balances: tokenBalances)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
    }
    
}

public extension RadixApplicationClient {
    
//    func observeBalances(ownedBy owner: AddressConvertible) -> AnyPublisher<TokenBalances, Never> {
//
//        self.observeBalanceReferences(at: owner.address)
//            .flatMap { state -> AnyPublisher<TokenBalances, Never> in
//                Publishers.Sequence<[TokenReferenceBalance], Never>(sequence: state.tokenReferenceBalances)
//                    .flatMap { [unowned self] tokenReferenceBalance -> AnyPublisher<TokenBalance, Never> in
//                        self.observeTokenDefinitions(at: tokenReferenceBalance.tokenResourceIdentifier.address)
//                            .tryMap { tokenDefinitionState -> TokenBalance in
//
//                                guard
//                                    case let rri = tokenReferenceBalance.tokenResourceIdentifier,
//                                    let tokenDefinition = tokenDefinitionState.tokenDefinition(identifier: rri)
//                                    else { incorrectImplementation("Expected token definition") }
//
//                                return try TokenBalance(tokenDefinition: tokenDefinition, tokenReferenceBalance: tokenReferenceBalance)
//                        }
//                        .crashOnFailure()
//                    }
//                    .collect(state.tokenReferenceBalances.count)
//                    .eraseToAnyPublisher()
//                    .map { (tokenBalances: [TokenBalance]) -> TokenBalances in
//                        TokenBalances(balances: tokenBalances)
//                    }
//                    .eraseToAnyPublisher()
//        }
//        .eraseToAnyPublisher()
//    }
    
    func observeBalances(ownedBy owner: AddressConvertible) -> AnyPublisher<TokenBalances, Never> {
        TokenBalancesReducer.usingApplicationClient(self).tokenBalancesOfAddress(owner.address)
    }
}

// MARK: StateSubscriber
public extension RadixApplicationClient {
    
    func observeState<State>(
        ofType stateType: State.Type,
        at address: Address
    ) -> AnyPublisher<State, Never>
        where State: ApplicationState {
            return stateSubscriber.observeState(ofType: stateType, at: address)
    }
}

// MARK: TransactionSubscriber
public extension RadixApplicationClient {
    func observeTransactions(at address: Address) -> AnyPublisher<ExecutedTransaction, Never> {
        return transactionSubscriber.observeTransactions(at: address)
    }
}

// MARK: TokenDefinitionsState Observation
public extension RadixApplicationClient {
    func observeTokenDefinitions(at address: Address) -> AnyPublisher<TokenDefinitionsState, Never> {
        return observeState(ofType: TokenDefinitionsState.self, at: address)
    }
    
    func observeTokenDefinition(identifier: ResourceIdentifier) -> AnyPublisher<TokenDefinition, Never> {
        let address = identifier.address
        return observeTokenDefinitions(at: address).map {
            $0.tokenDefinition(identifier: identifier)
        }.replaceNilWithEmpty()
    }
    
    func observeTokenState(identifier: ResourceIdentifier) -> AnyPublisher<TokenState, Never> {
        let address = identifier.address
        return observeTokenDefinitions(at: address).map {
            $0.tokenState(identifier: identifier)
        }.replaceNilWithEmpty()
    }
}

// MARK: TokenBalanceReferencesState Observation
public extension RadixApplicationClient {
    func observeBalanceReferences(at address: Address) -> AnyPublisher<TokenBalanceReferencesState, Never> {
        return observeState(ofType: TokenBalanceReferencesState.self, at: address)
    }
}

// MARK: Magical
public extension RadixApplicationClient {
    var magic: Magic { universeConfig.magic }
}

// MARK: ActiveAccountOwner
public extension RadixApplicationClient {
    var addressOfActiveAccount: Address { snapshotActiveAccount.addressFromMagic(magic) }
    
    func observeAddressOfActiveAccount() -> AnyPublisher<Address, Never> {
        identity.activeAccountObservable
            .map { newActiveAccount in
                newActiveAccount.addressFromMagic(self.magic)
        }
        .eraseToAnyPublisher()
    }
    
    func observeActiveAccount() -> AnyPublisher<Account, Never> {
        identity.activeAccountObservable
    }
}

// MARK: Public
public extension RadixApplicationClient {
    
    var universeConfig: UniverseConfig { universe.config }
    
    var nativeTokenDefinition: TokenDefinition { universe.nativeTokenDefinition }
    
    var nativeTokenIdentifier: ResourceIdentifier { nativeTokenDefinition.tokenDefinitionReference }
    
    @discardableResult
    func changeAccount(accountSelector: AbstractIdentity.AccountSelector) -> Account? {
        identity.selectAccount(accountSelector)
    }
    
    func changeAccount(to selectedAccount: Account) {
        identity.changeAccount(to: selectedAccount)
    }
    
    func addAccount(_ newAccount: Account) {
        identity.addAccount(newAccount)
    }
    
    func pull(address: Address) -> Cancellable {
        atomPuller.pull(address: address)
    }
    
    func pull() -> Cancellable {
        pull(address: addressOfActiveAccount)
    }
    
    var snapshotActiveAccount: Account {
        identity.snapshotActiveAccount
    }
}

// MARK: - Private
private extension RadixApplicationClient {
    var atomPuller: AtomPuller { universe.atomPuller }
}
