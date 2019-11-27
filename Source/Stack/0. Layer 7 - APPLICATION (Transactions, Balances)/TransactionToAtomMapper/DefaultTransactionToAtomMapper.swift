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

public final class DefaultTransactionToAtomMapper: TransactionToAtomMapper, Throwing {
    
    private let atomStore: AtomStore
    
    /// A list of type-erased mappers from requested/pending `UserAction` to `ParticleGroups`s.
    /// Stateless and Stateful ActionToParticleGroupMapper's merged together as Stateful mappers.
    /// A `Stateless` mapper has no dependency on ledger/application state, e.g. sending a message,
    /// transferring tokens on the other hand is dependent on your balance, thus `Stateful`.
    private let actionMappers: [AnyStatefulActionToParticleGroupsMapper]
    
    public init(
        atomStore: AtomStore,
        actionToParticleGroupsMappers: [AnyStatefulActionToParticleGroupsMapper]
        ) {
        self.atomStore = atomStore
        self.actionMappers = actionToParticleGroupsMappers
    }
}

public extension DefaultTransactionToAtomMapper {
    convenience init(
        atomStore: AtomStore,
        statelessActionToParticleGroupsMappers: [AnyStatelessActionToParticleGroupsMapper] = .default,
        statefulActionToParticleGroupsMappers: [AnyStatefulActionToParticleGroupsMapper] = .default
        ) {
        
        let actionToParticleGroupsMappers: [AnyStatefulActionToParticleGroupsMapper] = {
            let statefulFromStateless = statelessActionToParticleGroupsMappers.map {
                AnyStatefulActionToParticleGroupsMapper(anyStatelessMapper: $0)
            }
            return statefulActionToParticleGroupsMappers + statefulFromStateless
        }()
        
        self.init(
            atomStore: atomStore,
            actionToParticleGroupsMappers: actionToParticleGroupsMappers
        )
    }
}

public typealias Throws<Output, Failure: Error> = Output

public extension DefaultTransactionToAtomMapper {
    func atomFrom(transaction: Transaction, addressOfActiveAccount: Address) throws -> Throws<Atom, ActionsToAtomError> {
        
        let temporaryStore = TemporaryLocalAtomStore(
            actionMappers: actionMappers,
            addressOfActiveAccount: addressOfActiveAccount
        ) { [weak self] in
            guard let self = self else { return [] }
            return self.atomStore.upParticles(at: $0)
        }

        do {
            try transaction.addressesOfActionsAreInTheSameUniverseAs(activeAddress: addressOfActiveAccount)
            
            let particleGroups = try temporaryStore.particleGroupsFromActions(transaction.actions)
            
            let atom = Atom(particleGroups: particleGroups)
            try Addresses.allInSameUniverse(atom.addresses().map { $0 })
            return atom
        } catch let actionsToAtomError as ActionsToAtomError {
            throw actionsToAtomError
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }

    }
}

// MARK: Throwing
public extension DefaultTransactionToAtomMapper {
    typealias Error = ActionsToAtomError
}

// MARK: TemporaryLocalAtomStore
private extension DefaultTransactionToAtomMapper {
    final class TemporaryLocalAtomStore {
        
        private var accumulatedSpunParticles = [AnySpunParticle]()
        private let actionMappers: [AnyStatefulActionToParticleGroupsMapper]
        private let addressOfActiveAccount: Address
        private let persistedParticlesAccessor: (Address) -> [SpunParticleContainer]
        
        fileprivate init(
            actionMappers: [AnyStatefulActionToParticleGroupsMapper],
            addressOfActiveAccount: Address,
            persistedParticlesAccessor: @escaping (Address) -> [SpunParticleContainer]
        ) {
            self.actionMappers = actionMappers
            self.addressOfActiveAccount = addressOfActiveAccount
            self.persistedParticlesAccessor = persistedParticlesAccessor
        }
    }
}

extension DefaultTransactionToAtomMapper.TemporaryLocalAtomStore {
    
    fileprivate func particleGroupsFromActions(_ userAction: [UserAction]) throws -> Throws<ParticleGroups, ActionsToAtomError> {
        var particleGroupsList = [ParticleGroup]()
        
        for action in userAction {
            let particleGroups = try particleGroupFromAction(action)
            accumulatedSpunParticles.append(contentsOf: particleGroups.spunParticles)
            particleGroupsList.append(contentsOf: particleGroups)
        }
        
        return ParticleGroups(particleGroupsList)
    }
    
    private func particleGroupFromAction(_ action: UserAction) throws -> Throws<ParticleGroups, ActionsToAtomError> {
        let statefulMapper = actionMapperFor(action: action)
        let requiredState = self.requiredState(for: action)
        
        let persistedUpParticles = requiredState.flatMap { requiredStateContext in
            self.persistedParticlesAccessor(requiredStateContext.address)
                .filter { type(of: $0.someParticle) == requiredStateContext.particleType }
        }
        
        let upParticles = mergingParticles(persistedUpParticles: persistedUpParticles)
        
        return try statefulMapper.particleGroupsForAnAction(
            action,
            upParticles: upParticles,
            addressOfActiveAccount: addressOfActiveAccount
        )
    }
    
    private func mergingParticles(persistedUpParticles upParticlesFromStore: [SpunParticleContainer]) -> [AnyUpParticle] {
        var upParticlesAsSpunParticles = upParticlesFromStore.map { AnySpunParticle(spunParticle: $0) }
        for newParticle in accumulatedSpunParticles {
            let condition: (AnySpunParticle) -> Bool = {
                $0.someParticle.hashEUID == newParticle.someParticle.hashEUID
            }
            if upParticlesAsSpunParticles.contains(where: condition) {
                upParticlesAsSpunParticles.removeAll(where: condition)
            }
            upParticlesAsSpunParticles.append(newParticle)
        }
        return upParticlesAsSpunParticles.upParticles()
    }
    
    private func actionMapperFor(action: UserAction) -> AnyStatefulActionToParticleGroupsMapper {
        guard let mapper = actionMappers.first(where: { $0.matches(someAction: action) }) else {
            incorrectImplementation("Found no ActionToParticleGroupsMapper for action: \(action), you probably just added a new UserAction but forgot to add its corresponding mapper to the list?")
        }
        return mapper
    }
    
    private func requiredState(for action: UserAction) -> [AnyShardedParticleStateId] {
        guard let mapper = actionMappers.first(where: { (mapper) -> Bool in
            return mapper.matches(someAction: action)
        }) else { return [] }
        return mapper.requiredStateForAnAction(action)
    }
}

// MARK: Default Mappers
public extension Array where Element == AnyStatefulActionToParticleGroupsMapper {
    static var `default`: [AnyStatefulActionToParticleGroupsMapper] {
        return [
            AnyStatefulActionToParticleGroupsMapper(DefaultMintTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultBurnTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultTransferTokensActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultPutUniqueActionToParticleGroupsMapper()),
            AnyStatefulActionToParticleGroupsMapper(DefaultCreateTokenActionToParticleGroupsMapper())
        ]
    }
}

public extension Array where Element == AnyStatelessActionToParticleGroupsMapper {
    static var `default`: [AnyStatelessActionToParticleGroupsMapper] {
        return [
            AnyStatelessActionToParticleGroupsMapper(DefaultSendMessageActionToParticleGroupsMapper())
        ]
    }
}

