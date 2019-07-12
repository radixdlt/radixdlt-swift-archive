//
//  RadixApplicationClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import RxOptional

// swiftlint:disable file_length

public final class RadixApplicationClient {
    
    public let universe: RadixUniverse
    public private(set) var identity: AbstractIdentity
    public var activeAccount: Account
    
    private let atomToExecutedActionMappers: [AnyAtomToExecutedActionMapper]
    private let particlesToStateReducers: [AnyParticleReducer]
    
    /// Action to Particle Mappers which can mapToParticleGroups without any dependency on ledger state
    private let statelessActionToParticleGroupsMappers: [AnyStatelessActionToParticleGroupsMapper]
    
    /// Action to Particle Mappers which require dependencies on the ledger
    private let statefulActionToParticleGroupsMappers: [AnyStatefulActionToParticleGroupsMapper]
    
    private let feeMapper: FeeMapper
    
    private let disposeBag = DisposeBag()
    
    public init(
        identity: AbstractIdentity,
        universe: RadixUniverse,
        feeMapper: FeeMapper = DefaultProofOfWorkWorker(),
        atomToExecutedActionMappers: [AnyAtomToExecutedActionMapper] = .default,
        particlesToStateReducers: [AnyParticleReducer] = .default,
        statelessActionToParticleGroupsMappers: [AnyStatelessActionToParticleGroupsMapper] = .default,
        statefulActionToParticleGroupsMappers: [AnyStatefulActionToParticleGroupsMapper] = .default,
        selectActiveAccount accountSelection: AbstractIdentity.AccountSelector = { $0[0] }
    ) {
        self.universe = universe
        self.identity = identity
        
        self.atomToExecutedActionMappers = atomToExecutedActionMappers
        self.particlesToStateReducers = particlesToStateReducers
        self.statelessActionToParticleGroupsMappers = statelessActionToParticleGroupsMappers
        self.statefulActionToParticleGroupsMappers = statefulActionToParticleGroupsMappers
        self.activeAccount = identity.selectAccount(accountSelection)
        self.feeMapper = feeMapper
    }
}

public extension RadixApplicationClient {
    
    convenience init(bootstrapConfig: BootstrapConfig, identity: AbstractIdentity) {
        let universe = DefaultRadixUniverse(bootstrapConfig: bootstrapConfig)
        self.init(identity: identity, universe: universe)
    }

    func observeState<State>(ofType stateType: State.Type, at address: Address) -> Observable<State> where State: ApplicationState {
        let reducer = particlesToStateReducer(for: stateType)
        return atomStore.onSync(address: address)
            .map { [unowned self] date in
                let upParticles = self.atomStore.upParticles(at: address, stagedUuid: nil)
                log.error("Reducing state from #\(upParticles.count) UP particles")
                let reducedState = reducer.reduceFromInitialState(particles: upParticles)
                log.error("Reduced state of type: \(type(of: reducedState)), to value: \(reducedState)")
                return reducedState
        }
    }
    
    func observeActions<ExecutedAction>(ofType actionType: ExecutedAction.Type, at address: Address) -> Observable<ExecutedAction> {
        
        let mapper = atomToExecutedActionMapper(for: actionType)
        let account = activeAccount

        return atomStore.atomObservations(of: address)
            .filterMap { (atomObservation: AtomObservation) -> FilterMap<Atom> in
                guard case .store(let atom, _, _) = atomObservation else { return .ignore }
                return .map(atom)
            }.flatMap { mapper.map(atom: $0, account: account) }
    }
    
    func pull(address: Address) -> Disposable {
        return atomPuller.pull(address: address).subscribe()
    }
    
    func addFee(to atom: Atom) -> Single<AtomWithFee> {
        return feeMapper.feeBasedOn(
            atom: atom,
            universeConfig: universeConfig,
            key: activeAccount.publicKey
        )
    }
    
    func execute(
        actions: [UserAction],
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent
        ) -> ResultOfUserAction {
        let transaction = Transaction(api: self)
        actions.forEach { transaction.stage(action: $0) }
        return transaction.commitAndPush(ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
 
    func observeTokenDefinition(identifier: ResourceIdentifier) -> Observable<TokenDefinition> {
        let address = identifier.address
        return observeTokenDefinitions(at: address).map {
            $0.tokenDefinition(identifier: identifier)
        }.ifNilReturnEmpty()
    }
    
    func observeBalances(at address: Address) -> Observable<TokenBalances> {
        return Observable.combineLatest(
            self.observeBalanceReferences(at: address),
            self.observeTokenDefinitions(at: address)
        ) {
            try TokenBalances(
                balanceReferencesState: $0,
                tokenDefinitionsState: $1
            )
        }.debug()
    }
    
    // MARK: - AccountBalance
    func observeBalance(of tokenIdentifier: ResourceIdentifier, for address: Address) -> Observable<TokenBalance?> {
        return observeBalances(at: address).map {
            $0.balance(of: tokenIdentifier)
        }
    }
    
    // MARK: - History of Executed Actions
    func observeTokenTransfers(toOrFrom address: Address) -> Observable<TransferTokenAction> {
        return observeActions(ofType: TransferTokenAction.self, at: address)
    }
    
    func observeMessages(toOrFrom address: Address) -> Observable<SentMessage> {
        return observeActions(ofType: SentMessage.self, at: address)
    }
    
    func create(
        token createTokenAction: CreateTokenAction,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        return execute(action: createTokenAction, ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
    
    func transfer(
        tokens transferTokensAction: TransferTokenAction,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        return self.execute(action: transferTokensAction, ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
    
    func send(
        message sendMessageAction: SendMessageAction,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        return self.execute(action: sendMessageAction, ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
    
    func execute(
        action: UserAction,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        return execute(actions: [action], ifNoSigningKeyPresent: noKeyPresentStrategy)
    }

    func sendPlainTextMessage(
        _ plainText: String,
        encoding: String.Encoding = .default,
        to recipient: Ownable,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        
        let sendMessageAction = SendMessageAction.plainText(from: addressOfActiveAccount, to: recipient, text: plainText, encoding: encoding)
        return self.send(message: sendMessageAction, ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
    
    func sendEncryptedMessage(
        _ textToEncrypt: String,
        encoding: String.Encoding = .default,
        to recipient: Ownable,
        canAlsoBeDecryptedBy extraDecryptors: [Ownable]? = nil,
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) -> ResultOfUserAction {
        
        let sendMessageAction = SendMessageAction.encryptedDecryptableBySenderAndRecipient(
            and: extraDecryptors,
            from: addressOfActiveAccount,
            to: recipient,
            text: textToEncrypt,
            encoding: encoding
        )
        
        return self.send(message: sendMessageAction, ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
 
    var nativeTokenIdentifier: ResourceIdentifier {
        return nativeTokenDefinition.tokenDefinitionReference
    }
    
    var addressOfActiveAccount: Address {
        return activeAccount.addressFromMagic(magic)
    }
    
    func addressOf(account: Account) -> Address {
        return account.addressFromMagic(magic)
    }

    /// Returns a hot observable of the latest state of token definitions at the user's address
    func observeMyTokenDefinitions() -> Observable<TokenDefinitionsState> {
        return observeTokenDefinitions(at: addressOfActiveAccount)
    }
    
    func observeMyTokenTransfers() -> Observable<TransferTokenAction> {
        return observeTokenTransfers(toOrFrom: addressOfActiveAccount)
    }
    
    func observeMyBalances() -> Observable<TokenBalances> {
        return observeBalances(at: addressOfActiveAccount)
    }
    
    func observeMyBalance(of tokenIdentifier: ResourceIdentifier) -> Observable<TokenBalance?> {
        return observeBalance(of: tokenIdentifier, for: addressOfActiveAccount)
    }
    
    func observeMyBalanceOfNativeTokens() -> Observable<TokenBalance?> {
        return observeMyBalance(of: nativeTokenIdentifier)
    }
    
    func observeMyBalanceOfNativeTokensOrZero() -> Observable<TokenBalance> {
        return observeMyBalanceOfNativeTokens()
            .replaceNilWith(TokenBalance.zero(token: nativeTokenDefinition, ownedBy: addressOfActiveAccount))
    }
    
    func observeMyMessages() -> Observable<SentMessage> {
        return observeMessages(toOrFrom: addressOfActiveAccount)
    }
    
    func pull() -> Disposable {
        return pull(address: addressOfActiveAccount)
    }
    
    func balanceOfNativeTokensOrZero(for address: Address) -> Observable<TokenBalance> {
        return observeBalance(of: nativeTokenIdentifier, for: address)
            .replaceNilWith(TokenBalance.zero(token: nativeTokenDefinition, ownedBy: address))
    }
    
    var universeConfig: UniverseConfig {
        return universe.config
    }
    
    var magic: Magic {
        return universeConfig.magic
    }
    
    var nativeTokenDefinition: TokenDefinition {
        return universe.nativeTokenDefinition
    }
    
    @discardableResult
    func changeAccount(accountSelector: AbstractIdentity.AccountSelector) -> Account? {
        return identity.selectAccount(accountSelector)
    }

    func createToken(
        name: Name,
        symbol: Symbol,
        description: Description,
        supply initialSupplyType: CreateTokenAction.InitialSupply,
        granularity: Granularity = .default,
        ifNoSigningKeyPresent: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent = .throwErrorDirectly
    ) throws -> ResultOfUserAction {
        
        let createTokenAction = try CreateTokenAction(
            creator: addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            supply: initialSupplyType,
            granularity: granularity
        )
        
        return self.create(
            token: createTokenAction,
            ifNoSigningKeyPresent: ifNoSigningKeyPresent
        )
    }
}

// MARK: - Internal
internal extension RadixApplicationClient {
    func observeTokenDefinitions(at address: Address) -> Observable<TokenDefinitionsState> {
        return observeState(ofType: TokenDefinitionsState.self, at: address).debug()
    }
    
    func observeBalanceReferences(at address: Address) -> Observable<TokenBalanceReferencesState> {
        return observeState(ofType: TokenBalanceReferencesState.self, at: address).debug()
    }
    
    var atomPuller: AtomPuller {
        return universe.atomPuller
    }
    
    var atomStore: AtomStore {
        return universe.atomStore
    }
    
    func actionMapperFor(action: UserAction) -> AnyStatefulActionToParticleGroupsMapper {
        guard let mapper = actionMappers.first(where: { $0.matches(someAction: action) }) else {
            incorrectImplementation("Found no ActionToParticleGroupsMapper for action: \(action), you probably just added a new UserAction but forgot to add its corresponding ActionToParticleGroupsMapper to the list?")
        }
        return mapper
    }
    
    func requiredState(for action: UserAction) -> [AnyShardedParticleStateId] {
        guard let mapper = actionMappers.first(where: { (mapper) -> Bool in
            return mapper.matches(someAction: action)
        }) else { return [] }
        return mapper.requiredStateForAnAction(action)
    }
    
    func sign(atom: Single<UnsignedAtom>, ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent) -> Single<SignedAtom> {
        if activeAccount.privateKey == nil, case .throwErrorDirectly = noKeyPresentStrategy {
            return Single.error(SigningError.noSigningKeyPresentButWasExpectedToBe)
        }
        return atom.flatMap { [unowned self] in
            try self.activeAccount.sign(atom: $0)
        }
    }
    
    func createAtomSubmission(atom atomSingle: Single<SignedAtom>, completeOnAtomStoredOnly: Bool, originNode: Node?) -> ResultOfUserAction {
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
        
        let result = ResultOfUserAction(updates: updates, cachedAtom: cachedAtom)
        result.connect().disposed(by: disposeBag)
        return result
    }
}

// MARK: - Private
private extension RadixApplicationClient {
    
    /// Stateless and Stateful ActionToParticleGroupMapper's merged as Stateful mappers
    var actionMappers: [AnyStatefulActionToParticleGroupsMapper] {
        let statefulFromStateless = statelessActionToParticleGroupsMappers.map {
            AnyStatefulActionToParticleGroupsMapper(anyStatelessMapper: $0)
        }
        let merged = statefulActionToParticleGroupsMappers + statefulFromStateless
        return merged
    }

    func atomToExecutedActionMapper<ExecutedAction>(for actionType: ExecutedAction.Type) -> SomeAtomToExecutedActionMapper<ExecutedAction> {
        guard let mapper = atomToExecutedActionMappers.first(where: { $0.matches(actionType: actionType) }) else {
            fatalError("found no mapper")
        }
        do {
            return try SomeAtomToExecutedActionMapper(any: mapper)
        } catch {
            fatalError("bad mapper")
        }
    }
    
    func particlesToStateReducer<State>(for stateType: State.Type) -> SomeParticleReducer<State> where State: ApplicationState {
        guard let reducer = particlesToStateReducers.first(where: {  $0.matches(stateType: stateType) }) else {
            incorrectImplementation("no reducer")
        }
        // swiftlint:disable:next force_try
        return try! SomeParticleReducer<State>(any: reducer)
    }
}

