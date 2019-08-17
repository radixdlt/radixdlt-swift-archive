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
import RxSwift
import RxSwiftExt
import RxOptional

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
    
    /// The chosen Radix universe, a network of nodes running a specific version of the Radix Node Runner software
    public let universe: RadixUniverse
    
    /// A holder of accounts belonging to the same person, with or without signing (`private`) keys.
    public private(set) var identity: AbstractIdentity
    
    /// Preparing and sending of Atoms to Radix Network
    private let transactionMaker: TransactionMaker
    
    /// A subscriber of state, derived from particles
    private let stateSubscriber: StateSubscriber
    
    /// A subscriber of exectued transactions at a given address
    private let transactionSubscriber: TransactionSubscriber

    private let disposeBag = DisposeBag()
    
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
    
    /// Initializes a RadixApplicationClient from a BootstrapConfig
    convenience init(bootstrapConfig: BootstrapConfig, identity: AbstractIdentity) {
        let universe = DefaultRadixUniverse(bootstrapConfig: bootstrapConfig)
        let atomStore = universe.atomStore
        let activeAccount = identity.activeAccountObservable
        
        let transactionMaker = DefaultTransactionMaker(
            activeAccount: activeAccount,
            universe: universe
        )
        
        let stateSubscriber = DefaultStateSubsciber(
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
    func transactionFromAtom(_ atom: Atom) -> Observable<ExecutedTransaction> {
        return transactionSubscriber.transactionFromAtom(atom)
    }
}

// MARK: TokenCreating
public extension RadixApplicationClient {
    func create(token createTokenAction: CreateTokenAction) -> ResultOfUserAction {
        return execute(actions: createTokenAction)
    }
    
    /// Returns a hot observable of the latest state of token definitions at the user's address
    func observeMyTokenDefinitions() -> Observable<TokenDefinitionsState> {
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
    
    func observeTokenTransfers(toOrFrom address: Address) -> Observable<TransferTokensAction> {
        return observeActions(ofType: TransferTokensAction.self, at: address)
    }
}

// MARK: MessageSending
public extension RadixApplicationClient {
    func send(message sendMessageAction: SendMessageAction) -> ResultOfUserAction {
        return execute(actions: sendMessageAction)
    }
    
    func observeMessages(toOrFrom address: Address) -> Observable<SendMessageAction> {
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
public extension RadixApplicationClient {
    
    func observeBalances(ownedBy owner: AddressConvertible) -> Observable<TokenBalances> {
        return observeBalanceReferences(at: owner.address).flatMap {
            Observable.combineLatest($0.dictionary.values
                .map { tokenReferenceBalance -> Observable<TokenBalance> in
                    let rriOfToken = tokenReferenceBalance.tokenResourceIdentifier
                    return self.observeTokenDefinitions(at: rriOfToken.address).map { tokenDefinitionState -> TokenBalance in
                        
                        guard let tokenDefinition = tokenDefinitionState.tokenDefinition(identifier: rriOfToken) else { incorrectImplementation("Expected token definition") }
                        
                        return try TokenBalance(tokenDefinition: tokenDefinition, tokenReferenceBalance: tokenReferenceBalance)
                    }
            }) { $0 } /* Observable.combineLatest continued */
        }.map { TokenBalances(balances: $0) }
    }
}

// MARK: StateSubscriber
public extension RadixApplicationClient {
    
    func observeState<State>(
        ofType stateType: State.Type,
        at address: Address
    ) -> Observable<State>
        where State: ApplicationState {
        return stateSubscriber.observeState(ofType: stateType, at: address)
    }
}

// MARK: TransactionSubscriber
public extension RadixApplicationClient {
    func observeTransactions(at address: Address) -> Observable<ExecutedTransaction> {
        return transactionSubscriber.observeTransactions(at: address)
    }
}

// MARK: TokenDefintionsState Observation
public extension RadixApplicationClient {
    func observeTokenDefinitions(at address: Address) -> Observable<TokenDefinitionsState> {
        return observeState(ofType: TokenDefinitionsState.self, at: address)
    }
    
    func observeTokenDefinition(identifier: ResourceIdentifier) -> Observable<TokenDefinition> {
        let address = identifier.address
        return observeTokenDefinitions(at: address).map {
            $0.tokenDefinition(identifier: identifier)
            }.ifNilReturnEmpty()
    }
    
    func observeTokenState(identifier: ResourceIdentifier) -> Observable<TokenState> {
        let address = identifier.address
        return observeTokenDefinitions(at: address).map {
            $0.tokenState(identifier: identifier)
            }.ifNilReturnEmpty()
    }
}

// MARK: TokenBalanceReferencesState Observation
public extension RadixApplicationClient {
    func observeBalanceReferences(at address: Address) -> Observable<TokenBalanceReferencesState> {
        return observeState(ofType: TokenBalanceReferencesState.self, at: address)
    }
}

// MARK: Magical
public extension RadixApplicationClient {
    var magic: Magic { universeConfig.magic }
}

// MARK: ActiveAccountOwner
public extension RadixApplicationClient {
    var addressOfActiveAccount: Address { activeAccount.addressFromMagic(magic) }
}

// MARK: Public
public extension RadixApplicationClient {
    
    var universeConfig: UniverseConfig { universe.config }
    
    var nativeTokenDefinition: TokenDefinition { universe.nativeTokenDefinition }
 
    var nativeTokenIdentifier: ResourceIdentifier { nativeTokenDefinition.tokenDefinitionReference }
    
    @discardableResult
    func changeAccount(accountSelector: AbstractIdentity.AccountSelector) -> Account? {
        return identity.selectAccount(accountSelector)
    }
    
    func pull(address: Address) -> Disposable {
        return atomPuller.pull(address: address).subscribe()
    }
    
    func pull() -> Disposable {
        return pull(address: addressOfActiveAccount)
    }
}

// MARK: - Private
private extension RadixApplicationClient {
    var atomPuller: AtomPuller { universe.atomPuller }
    
    var activeAccount: Account { identity.activeAccount }
}
