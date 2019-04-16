//
//  ParticleGroups.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// Collection of ParticleGroups
public struct ParticleGroups:
    ArrayCodable,
    DSONArrayConvertible {
 // swiftlint:enable colon
    
    public let particleGroups: [ParticleGroup]
    public init(particleGroups: [ParticleGroup] = []) {
        self.particleGroups = particleGroups
    }
}

// MARK: - ArrayDecodable
public extension ParticleGroups {
    typealias Element = ParticleGroup
    var elements: [Element] {
        return particleGroups
    }
    init(elements: [Element]) {
        self.init(particleGroups: elements)
    }
}

public extension Sequence where Element == ParticleGroup {
    func firstParticle<P>(ofType type: P.Type) -> P? {
        return compactMap { $0.firstParticle(ofType: type) }.first
    }
}

public extension ParticleGroup {
    func firstParticle<P>(ofType type: P.Type) -> P? {
        return spunParticles.compactMap { $0.particle as? P }.first
    }
}
