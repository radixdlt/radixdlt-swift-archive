//
//  Atom+Sequence.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Sequence where Element == Atom {
    func particleGroups() -> [ParticleGroup] {
        return flatMap({ $0.particleGroups })
    }
    
    func spunParticles(spin: Spin? = nil) -> [AnySpunParticle] {
        let particles = particleGroups().flatMap { $0.spunParticles }
        guard let spin = spin else {
            return particles
        }
        return particles.filter(spin: spin)
    }
    
    func upParticles<P>(type: P.Type) -> [P] where P: ParticleConvertible {
        return spunParticles(spin: .up).compactMap(type: type)
    }

}
