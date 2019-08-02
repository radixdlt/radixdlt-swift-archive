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

// swiftlint:disable file_length opening_brace colon
public final class RadixApplicationClient:
    AccountBalancing,
    TokenTransferring,
    TokenCreating,
    TokenMinting,
    MessageSending,
    AddressOfAccountDeriving,
    ActiveAccountOwner,
    Magical
{
    // swiftlint:enable opening_brace colon
    
    /// The chosen Radix universe, a network of nodes running a specific version of the Radix Node Runner software
    public let universe: RadixUniverse
    
    /// A holder of accounts belonging to the same person, with or without signing (`private`) keys.
    public private(set) var identity: AbstractIdentity
    
    /// Not all accounts of `identity` contain a signing (`private`) key, but all user actions (such as transferring tokens, sending messages etc) requires a cryptographic signature by the signing key, this strategy specifies what to do in those scenarios, and can be changed later in time.
    public var strategyNoSigningKeyIsPresent: StrategyNoSigningKeyIsPresent = .throwErrorDirectly
    
    /// A list of type-erased mappers from `Atom` to `ExecutedAction` (the already executed version of `UserAction`).
    private let atomToExecutedActionMappers: [AnyAtomToExecutedActionMapper]
    
    /// A list of type-erased reducers of `Particle`s into `ApplicationState`, from which we can derive e.g. token balance and token definitions.
    private let particlesToStateReducers: [AnyParticleReducer]
    
    /// A list of type-erased mappers from requested/pending `UserAction` to `ParticleGroups`s.
    /// Stateless and Stateful ActionToParticleGroupMapper's merged together as Stateful mappers.
    /// A `Stateless` mapper has no dependency on ledger/application state, e.g. sending a message,
    /// transferring tokens on the other hand is dependent on your balance, thus `Stateful`.
    private let actionMappers: [AnyStatefulActionToParticleGroupsMapper]

    /// A mapper from `Atom` to `AtomWithFee`
    private let feeMapper: FeeMapper
    
    private let disposeBag = DisposeBag()
    
    public init(
        identity: AbstractIdentity,
        universe: RadixUniverse,
        feeMapper: FeeMapper = DefaultProofOfWorkWorker(),
        atomToExecutedActionMappers: [AnyAtomToExecutedActionMapper] = .default,
        particlesToStateReducers: [AnyParticleReducer] = .default,
        statelessActionToParticleGroupsMappers: [AnyStatelessActionToParticleGroupsMapper] = .default,
        statefulActionToParticleGroupsMappers: [AnyStatefulActionToParticleGroupsMapper] = .default
    ) {
        self.universe = universe
        self.identity = identity
        
        self.feeMapper = feeMapper
        self.atomToExecutedActionMappers = atomToExecutedActionMappers
        self.particlesToStateReducers = particlesToStateReducers
        
        self.actionMappers = {
            let statefulFromStateless = statelessActionToParticleGroupsMappers.map {
                AnyStatefulActionToParticleGroupsMapper(anyStatelessMapper: $0)
            }
            return statefulActionToParticleGroupsMappers + statefulFromStateless
        }()
    }
}

// MARK: Convenience Init
public extension RadixApplicationClient {
    
    /// Initializes a RadixApplicationClient from a BootstrapConfig
    convenience init(bootstrapConfig: BootstrapConfig, identity: AbstractIdentity) {
        let universe = DefaultRadixUniverse(bootstrapConfig: bootstrapConfig)
        self.init(identity: identity, universe: universe)
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

// MARK: TokenTransferring
public extension RadixApplicationClient {
    func transfer(tokens transferTokensAction: TransferTokenAction) -> ResultOfUserAction {
        return execute(actions: transferTokensAction)
    }
    
    func observeTokenTransfers(toOrFrom address: Address) -> Observable<TransferredTokens> {
        return observeActions(ofType: TransferredTokens.self, at: address)
    }
}

// MARK: MessageSending
public extension RadixApplicationClient {
    func send(message sendMessageAction: SendMessageAction) -> ResultOfUserAction {
        return execute(actions: sendMessageAction)
    }
    
    func observeMessages(toOrFrom address: Address) -> Observable<SentMessage> {
        return observeActions(ofType: SentMessage.self, at: address)
    }
}

// MARK: AccountBalancing
public extension RadixApplicationClient {
    
    func observeBalances(ownedBy owner: Ownable) -> Observable<TokenBalances> {
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

// MARK: Application State
public extension RadixApplicationClient {
    
    func observeState<State>(
        ofType stateType: State.Type,
        at address: Address
    ) -> Observable<State>
        where State: ApplicationState {
        
        let reducer = particlesToStateReducer(for: stateType)
        return atomStore.onSync(address: address)
            .map { [unowned self] date in
                let upParticles = self.atomStore.upParticles(at: address, stagedUuid: nil)
                let reducedState = reducer.reduceFromInitialState(upParticles: upParticles)
                return reducedState
        }
    }
    
    func observeActions<SpecificExecutedAction>(
        ofType actionType: SpecificExecutedAction.Type,
        at address: Address
    ) -> Observable<SpecificExecutedAction>
        where SpecificExecutedAction: ExecutedAction {
        
        let mapper = atomToExecutedActionMapper(for: actionType)
        let account = activeAccount

        return atomStore.atomObservations(of: address)
            .filterMap { (atomObservation: AtomObservation) -> FilterMap<Atom> in
                guard case .store(let atom, _, _) = atomObservation else { return .ignore }
                return .map(atom)
            }.flatMap { mapper.map(atom: $0, account: account) }
    }
    
    func observeTokenDefinitions(at address: Address) -> Observable<TokenDefinitionsState> {
        return observeState(ofType: TokenDefinitionsState.self, at: address)
    }
    
    func observeBalanceReferences(at address: Address) -> Observable<TokenBalanceReferencesState> {
        return observeState(ofType: TokenBalanceReferencesState.self, at: address)
    }
}

// MARK: Public
public extension RadixApplicationClient {
    
    var universeConfig: UniverseConfig {
        return universe.config
    }
    
    var magic: Magic {
        return universeConfig.magic
    }
    
    var nativeTokenDefinition: TokenDefinition {
        return universe.nativeTokenDefinition
    }
 
    var nativeTokenIdentifier: ResourceIdentifier {
        return nativeTokenDefinition.tokenDefinitionReference
    }
    
    var addressOfActiveAccount: Address {
        return activeAccount.addressFromMagic(magic)
    }
    
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

// MARK: - Private
private extension RadixApplicationClient {
    var atomPuller: AtomPuller {
        return universe.atomPuller
    }
    
    var atomStore: AtomStore {
        return universe.atomStore
    }
    
    var activeAccount: Account {
        return identity.activeAccount
    }

    func requiredState(for action: UserAction) -> [AnyShardedParticleStateId] {
        guard let mapper = actionMappers.first(where: { (mapper) -> Bool in
            return mapper.matches(someAction: action)
        }) else { return [] }
        return mapper.requiredStateForAnAction(action)
    }
    
    func addFee(to atom: Atom) -> Single<AtomWithFee> {
        return feeMapper.feeBasedOn(
            atom: atom,
            universeConfig: universeConfig,
            key: activeAccount.publicKey
        )
    }
    
    func sign(atom: Single<UnsignedAtom>) -> Single<SignedAtom> {
        if activeAccount.privateKey == nil, case .throwErrorDirectly = self.strategyNoSigningKeyIsPresent {
            return Single.error(SigningError.noSigningKeyPresentButWasExpectedToBe)
        }
        return atom.flatMap { [unowned self] in
            try self.activeAccount.sign(atom: $0)
        }
    }
    
    func createAtomSubmission(
        atom atomSingle: Single<SignedAtom>,
        completeOnAtomStoredOnly: Bool,
        originNode: Node?
    ) -> ResultOfUserAction {
        
        let cachedAtom = atomSingle.cache()
        let updates = cachedAtom
            .flatMapObservable { [unowned self] (atom: SignedAtom) -> Observable<SubmitAtomAction> in
                let initialAction: SubmitAtomAction
                
                if let originNode = originNode {
                    initialAction = SubmitAtomActionSend(atom: atom, node: originNode, isCompletingOnStoreOnly: completeOnAtomStoredOnly)
                } else {
                    initialAction = SubmitAtomActionRequest(atom: atom, isCompletingOnStoreOnly: completeOnAtomStoredOnly)
                }
                
                let status: Observable<SubmitAtomAction> = self.universe.networkController
                    .getActions()
                    .ofType(SubmitAtomAction.self)
                    .filter { $0.uuid == initialAction.uuid }
                    .takeWhile { !$0.isCompleted }
                
                self.universe.networkController.dispatch(nodeAction: initialAction)
                return status
            }.share(replay: 1, scope: .forever)
        
        let result = ResultOfUserAction(updates: updates, cachedAtom: cachedAtom) { [unowned self] in
            // Disposable from calling `connect`
            $0.disposed(by: self.disposeBag)
        }
        
        return result
    }
    
    func execute(actions: UserAction..., originNode: Node? = nil) -> ResultOfUserAction {
        let uuid = UUID()
        
        for action in actions {
            do {
                try stage(action: action, uuid: uuid)
            } catch {
                atomStore.clearStagedParticleGroups(for: uuid)
                let failed = FailedToStageAction(error: error, userAction: action)
                return ResultOfUserAction.failedToStageAction(failed)
            }
        }
        
        return commitAndPush(uuid: uuid, toNode: originNode)
    }
    
    func buildAtom(uuid: UUID) -> Single<UnsignedAtom> {
        guard let particleGroups = universe.atomStore.clearStagedParticleGroups(for: uuid) else {
            incorrectImplementation("Found no staged ParticleGroups for UUID: \(uuid), but expected to.")
        }
        let atom = Atom(particleGroups: particleGroups)
        
        return addFee(to: atom).map {
            try UnsignedAtom(atomWithPow: $0)
        }
    }
    
    func commitAndPush(uuid: UUID, toNode originNode: Node? = nil) -> ResultOfUserAction {
        
        log.verbose("Committing and pushing transaction (actions -> Atom -> POW -> Sign -> ResultOfUserAction)")
        
        let unsignedAtom = buildAtom(uuid: uuid)
        let signedAtom = sign(atom: unsignedAtom)
        
        return createAtomSubmission(
            atom: signedAtom,
            completeOnAtomStoredOnly: false,
            originNode: originNode
        )
    }
    
    func stage(action: UserAction, uuid: UUID) throws {
        let statefulMapper = actionMapperFor(action: action)
        let requiredState = self.requiredState(for: action)
        let particles = requiredState.flatMap { requiredStateContext in
            atomStore.upParticles(at: requiredStateContext.address, stagedUuid: uuid)
                .filter { type(of: $0.particle) == requiredStateContext.particleType }
        }
        try statefulMapper.particleGroupsForAnAction(action, upParticles: particles).forEach {
            atomStore.stageParticleGroup($0, uuid: uuid)
        }
    }
    
    func atomToExecutedActionMapper<ExecutedAction>(for actionType: ExecutedAction.Type) -> SomeAtomToExecutedActionMapper<ExecutedAction> {
        guard let mapper = atomToExecutedActionMappers.first(where: { $0.matches(actionType: actionType) }) else {
             incorrectImplementation("Found no AtomToExecutedActionMapper for action of type: \(actionType), you probably just added a new ExecutedAction but forgot to add its corresponding mapper to the list?")
        }
        do {
            return try SomeAtomToExecutedActionMapper(any: mapper)
        } catch { unexpectedlyMissedToCatch(error: error) }
    }
    
    func particlesToStateReducer<State>(for stateType: State.Type) -> SomeParticleReducer<State> where State: ApplicationState {
        guard let reducer = particlesToStateReducers.first(where: {  $0.matches(stateType: stateType) }) else {
            incorrectImplementation("Found no ParticleReducer for state of type: \(stateType), you probably just added a new ApplicationState but forgot to add its corresponding reducer to the list?")
        }
        do {
            return try SomeParticleReducer<State>(any: reducer)
        } catch { unexpectedlyMissedToCatch(error: error) }
    }
    
    func actionMapperFor(action: UserAction) -> AnyStatefulActionToParticleGroupsMapper {
        guard let mapper = actionMappers.first(where: { $0.matches(someAction: action) }) else {
            incorrectImplementation("Found no ActionToParticleGroupsMapper for action: \(action), you probably just added a new UserAction but forgot to add its corresponding mapper to the list?")
        }
        return mapper
    }
}
