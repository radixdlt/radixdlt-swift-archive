//
//  DefaultParticleStore.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultParticleStore: ParticleStore {
    private let atomStore: AtomStore
    private let cache = Cache<Address, Observable<SpunParticle>>()
    
    public init(atomStore: AtomStore) {
        self.atomStore = atomStore
    }
}

// MARK: - ParticleStore
public extension DefaultParticleStore {
    func particles(for address: Address) -> Observable<SpunParticle> {
        return cache.value(for: address) { [unowned self] in
            self.atomStore.atoms(for: address)
                .map { $0.atom }.filterNil()
                .flatMap { atom -> Observable<SpunParticle> in return Observable.from(atom.spunParticles()) }
                .filter { $0.particle.keyDestinations().contains(address.publicKey) }
                .replay(1)
        }
    }
}
