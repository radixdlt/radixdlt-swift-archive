//
//  DefaultRadixApplicationClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultRadixApplicationClient: RadixApplicationClient {
    
    public let universe: RadixUniverse
    public private(set) var identity: AbstractIdentity
    public var activeAccount: Account
    
    private let atomToExecutedActionMapper: [AnyAtomToExecutedActionMapper]
    private let particlesToStateReducers: [AnyParticleReducer]
    
    /// Action to Particle Mappers which can mapToParticleGroups without any dependency on ledger state
    private let statelessActionToParticleGroupsMappers: [AnyStatelessActionToParticleGroupsMapper]
    
    /// Action to Particle Mappers which require dependencies on the ledger
    private let statefulActionToParticleGroupsMappers: [AnyStatefulActionToParticleGroupsMapper]
    
    private let feeMapper: FeeMapper
    
    public init(
        identity: AbstractIdentity,
        universe: RadixUniverse,
        feeMapper: FeeMapper = DefaultProofOfWorkWorker(),
        atomToExecutedActionMapper: [AnyAtomToExecutedActionMapper] = .default,
        particlesToStateReducers: [AnyParticleReducer] = .default,
        statelessActionToParticleGroupsMappers: [AnyStatelessActionToParticleGroupsMapper] = .default,
        statefulActionToParticleGroupsMappers: [AnyStatefulActionToParticleGroupsMapper] = .default,
        selectActiveAccount accountSelection: AbstractIdentity.AccountSelector = { $0[0] }
    ) {
        self.universe = universe
        self.identity = identity
        
        self.atomToExecutedActionMapper = atomToExecutedActionMapper
        self.particlesToStateReducers = particlesToStateReducers
        self.statelessActionToParticleGroupsMappers = statelessActionToParticleGroupsMappers
        self.statefulActionToParticleGroupsMappers = statefulActionToParticleGroupsMappers
        self.activeAccount = identity.selectAccount(accountSelection)
        self.feeMapper = feeMapper
        
    }
}

public extension DefaultRadixApplicationClient {
    
    convenience init(bootstrapConfig: BootstrapConfig, identity: AbstractIdentity) {
        let universe = DefaultRadixUniverse(bootstrapConfig: bootstrapConfig)
        self.init(identity: identity, universe: universe)
    }
    
    func connectTo(node: FormattedURL) -> Completable {
        implementMe()
    }
}

private extension DefaultRadixApplicationClient {
    /// Stateless and Stateful ActionToParticleGroupMapper's merged as Stateful mappers
    var actionMappers: [AnyStatefulActionToParticleGroupsMapper] {
        let statefulFromStateless = statelessActionToParticleGroupsMappers.map {
            AnyStatefulActionToParticleGroupsMapper(anyStatelessMapper: $0)
        }
        let merged = statefulActionToParticleGroupsMappers + statefulFromStateless
        return merged
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
}

// MARK: - Public Implementation Of protocol methods in protocol declaration header
public extension DefaultRadixApplicationClient {
    func applicationState<State>(ofType stateType: State.Type, at address: Address) -> Observable<State> where State: ApplicationState {
        let reducer = particlesToStateReducer(for: stateType)
        return atomStore.onSync(address: address).mapToVoid().map { [unowned self] in
            self.atomStore.upParticles(at: address, stagedUuid: nil)
                .reduce(reducer.initialState, reducer.reduceThenCombine)
        }
    }
    
    func actions<ExecutedAction>(ofType actionType: ExecutedAction.Type, at address: Address) -> Observable<ExecutedAction> {
        implementMe()
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
        print("STAGING ACTIONs")
        actions.forEach { transaction.stage(action: $0) }
        print("ACTIONS staged, about to commitAndPush")
        return transaction.commitAndPush(ifNoSigningKeyPresent: noKeyPresentStrategy)
    }
    
}

internal final class Transaction {
    private let uuid = UUID()
    private unowned let api: DefaultRadixApplicationClient
    internal init(api: DefaultRadixApplicationClient) {
        self.api = api
    }
    
    func commitAndPush(
        ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent,
        toNode originNode: Node? = nil
    ) -> ResultOfUserAction {
        
        let unsignedAtom = buildAtom()
        let signedAtom = api.sign(atom: unsignedAtom, ifNoSigningKeyPresent: noKeyPresentStrategy)
        
        return api.createAtomSubmission(
            atom: signedAtom,
            completeOnAtomStoredOnly: false,
            originNode: originNode
        ).connect()
    }
    
    func stage(action: UserAction) {
        let statefulMapper = api.actionMapperFor(action: action)
        let requiredState = api.requiredState(for: action)
        let particles = requiredState.flatMap { requiredStateContext in
            api.atomStore.upParticles(at: requiredStateContext.address, stagedUuid: uuid)
                .filter { type(of: $0) == requiredStateContext.particleType }
        }
        do {
            try statefulMapper.particleGroupsForAnAction(action, upParticles: particles).forEach {
                api.atomStore.stateParticleGroup($0, uuid: uuid)
            }
        } catch {
            incorrectImplementation("unexpected error: \(error), when mapping action: \(action), using mapper: \(statefulMapper)")
        }
        
    }
    
    func buildAtom() -> Single<UnsignedAtom> {
        let particleGroups = api.universe.atomStore.clearStagedParticleGroups(for: uuid)
        let atom = Atom(particleGroups: particleGroups)
        let atomWithFee = api.addFee(to: atom)
        let unsignedAtom = atomWithFee.map {
            try UnsignedAtom(atomWithPow: $0)
        }
        return unsignedAtom
    }
}

public enum SigningError: Int, Swift.Error, Equatable {
    case noSigningKeyPresentButWasExpectedToBe
    case errorWhileSigning
}

public enum BuildAtomError: Int, Swift.Error {
    case noAtomsError
}

// MARK: - Private
private extension DefaultRadixApplicationClient {
    
    func sign(atom: Single<UnsignedAtom>, ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent) -> Single<SignedAtom> {
        if activeAccount.privateKey == nil, case .throwErrorDirectly = noKeyPresentStrategy {
            return Single.error(SigningError.noSigningKeyPresentButWasExpectedToBe)
        }
        return atom.flatMap { [unowned self] in
            try self.activeAccount.sign(atom: $0)
        }
    }
    
    func createAtomSubmission(atom atomSingle: Single<SignedAtom>, completeOnAtomStoredOnly: Bool, originNode: Node?) -> ResultOfUserAction {
        let updates = atomSingle.flatMapObservable { [unowned self] (atom: SignedAtom) -> Observable<SubmitAtomAction> in
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
        }
        
        return ResultOfUserAction(updates: updates)
        
    }
    
    func atomToActionToParticleGroupsMapper<ExecutedAction>(for actionType: ExecutedAction.Type) -> SomeAtomToExecutedActionMapper<ExecutedAction> {
        guard let mapper = atomToExecutedActionMapper.first(where: { $0.matches(actionType: actionType) }) else {
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

public extension ObservableType {
    func ofType<T>(_ type: T.Type) -> Observable<T> {
        return self.asObservable().map { (element: Element) -> T? in
            guard let casted = element as? T else { return nil }
            return casted
        }.ifNilReturnEmpty()
    }
}

// MARK: - Presets
public extension Array where Element == AnyAtomToExecutedActionMapper {
    static var `default`: [AnyAtomToExecutedActionMapper] {
        return [
            AnyAtomToExecutedActionMapper(DefaultAtomToTokenTransferMapper()),
            AnyAtomToExecutedActionMapper(DefaultAtomToDecryptedMessageMapper())
        ]
    }
}

public extension Array where Element == AnyParticleReducer {
    static var `default`: [AnyParticleReducer] {
        return [
            AnyParticleReducer(TokenBalanceReferencesReducer()),
            AnyParticleReducer(TokenDefinitionsReducer())
        ]
    }
}

public extension Array where Element == AnyStatefulActionToParticleGroupsMapper {
    static var `default`: [AnyStatefulActionToParticleGroupsMapper] {
        return [
            AnyStatefulActionToParticleGroupsMapper(DefaultMintTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultMintAndTransferTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultBurnTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultTransferTokensActionToParticleGroupsMapper())
        ]
    }
}

public extension Array where Element == AnyStatelessActionToParticleGroupsMapper {
    static var `default`: [AnyStatelessActionToParticleGroupsMapper] {
        return [
            AnyStatelessActionToParticleGroupsMapper(DefaultSendMessageActionToParticleGroupsMapper()),
            AnyStatelessActionToParticleGroupsMapper(DefaultCreateTokenActionToParticleGroupsMapper()),
            AnyStatelessActionToParticleGroupsMapper(DefaultPutUniqueActionToParticleGroupsMapper())
        ]
    }
}
