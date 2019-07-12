//
//  RadixApplicationClient+Transaction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

extension RadixApplicationClient {
    final class Transaction {
        private let uuid = UUID()
        private unowned let api: RadixApplicationClient
        internal init(api: RadixApplicationClient) {
            self.api = api
        }
        
        func commitAndPush(
            ifNoSigningKeyPresent noKeyPresentStrategy: StrategyForWhenActionRequiresSigningKeyWhichIsNotPresent,
            toNode originNode: Node? = nil
            ) -> ResultOfUserAction {
            
            log.verbose("Committing and pushing transaction (actions -> Atom -> POW -> Sign -> ResultOfUserAction)")
            
            let unsignedAtom = buildAtom() //.asObservable().share().asSingle()
            let signedAtom = api.sign(atom: unsignedAtom, ifNoSigningKeyPresent: noKeyPresentStrategy) //.asObservable().share().asSingle()
            
            return api.createAtomSubmission(
                atom: signedAtom,
                completeOnAtomStoredOnly: false,
                originNode: originNode
            )
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
            
            return api.addFee(to: atom).map {
                try UnsignedAtom(atomWithPow: $0)
            }
        }
    }
}
