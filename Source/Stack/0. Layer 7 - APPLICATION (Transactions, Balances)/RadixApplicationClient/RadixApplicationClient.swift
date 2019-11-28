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
    func make(transaction: Transaction, to originNode: Node?) -> PendingTransaction {
        transactionMaker.make(transaction: transaction, to: originNode)
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
    func transactionFromAtom(_ atom: Atom) -> AnyPublisher<ExecutedTransaction, AtomToTransactionMapperError> {
        return transactionSubscriber.transactionFromAtom(atom)
    }
}

// MARK: TokenCreating
public extension RadixApplicationClient {
    func createToken(action createTokenAction: CreateTokenAction) -> PendingTransaction {
        execute(actions: createTokenAction)
    }
    
    /// Returns a hot observable of the latest state of token definitions at the user's address
    func observeMyTokenDefinitions() -> AnyPublisher<TokenDefinitionsState, StateSubscriberError> {
        return observeTokenDefinitions(at: addressOfActiveAccount)
    }
}

// MARK: TokenMinting
public extension RadixApplicationClient {
    func mintTokens(action mintTokensAction: MintTokensAction) -> PendingTransaction {
        execute(actions: mintTokensAction)
    }
}

// MARK: TokenBurning
public extension RadixApplicationClient {
    func burnTokens(action burnTokensAction: BurnTokensAction) -> PendingTransaction {
        execute(actions: burnTokensAction)
    }
}

// MARK: TokenTransferring
public extension RadixApplicationClient {
    func transferTokens(action transferTokensAction: TransferTokensAction) -> PendingTransaction {
        execute(actions: transferTokensAction)
    }
    
    func observeTokenTransfers(toOrFrom address: Address) -> AnyPublisher<TransferTokensAction, AtomToTransactionMapperError> {
        return observeActions(ofType: TransferTokensAction.self, at: address)
    }
}

// MARK: MessageSending
public extension RadixApplicationClient {
    func sendMessage(action sendMessageAction: SendMessageAction) -> PendingTransaction {
        execute(actions: sendMessageAction)
    }
    
    func observeMessages(toOrFrom address: Address) -> AnyPublisher<SendMessageAction, AtomToTransactionMapperError> {
        return observeActions(ofType: SendMessageAction.self, at: address)
    }
}

// MARK: UniqueMaking
public extension RadixApplicationClient {
    func putUniqueId(action putUniqueAction: PutUniqueIdAction) -> PendingTransaction {
        execute(actions: putUniqueAction)
    }
}

// MARK: AccountBalancing
public extension RadixApplicationClient {

    func observeBalances(ownedBy owner: AddressConvertible) -> AnyPublisher<TokenBalances, TokenBalancesReducerError> {
        TokenBalancesReducer.usingApplicationClient(self).tokenBalancesOfAddress(owner.address)
    }
}

// MARK: StateSubscriber
public extension RadixApplicationClient {
    
    func observeState<State>(
        ofType stateType: State.Type,
        at address: Address
    ) -> AnyPublisher<State, StateSubscriberError> where State: ApplicationState {
        
        stateSubscriber.observeState(ofType: stateType, at: address)
    }
}

// MARK: TransactionSubscriber
public extension RadixApplicationClient {
    func observeTransactions(at address: Address) -> AnyPublisher<ExecutedTransaction, AtomToTransactionMapperError> {
        return transactionSubscriber.observeTransactions(at: address)
    }
}

// MARK: TokenDefinitionsState Observation
public extension RadixApplicationClient {
    func observeTokenDefinitions(at address: Address) -> AnyPublisher<TokenDefinitionsState, StateSubscriberError> {
        return observeState(ofType: TokenDefinitionsState.self, at: address)
    }
    
    func observeTokenDefinition(identifier: ResourceIdentifier) -> AnyPublisher<TokenDefinition, StateSubscriberError> {
        let address = identifier.address
        return observeTokenDefinitions(at: address).map {
            $0.tokenDefinition(identifier: identifier)
        }.replaceNilWithEmpty()
    }
    
    func observeTokenState(identifier: ResourceIdentifier) -> AnyPublisher<TokenState, StateSubscriberError> {
        let address = identifier.address
        return observeTokenDefinitions(at: address).map {
            $0.tokenState(identifier: identifier)
        }.replaceNilWithEmpty()
    }
}

// MARK: TokenBalanceReferencesState Observation
public extension RadixApplicationClient {
    func observeBalanceReferences(at address: Address) -> AnyPublisher<TokenBalanceReferencesState, StateSubscriberError> {
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
