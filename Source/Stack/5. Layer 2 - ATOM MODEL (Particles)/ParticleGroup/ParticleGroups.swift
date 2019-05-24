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

// MARK: - Convenience
public extension ParticleGroups {
    init(groups: ParticleGroup...) {
        self.init(particleGroups: groups)
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

// MARK: - To Atom
public extension ParticleGroups {
    func wrapInAtom() -> Atom {
        return Atom(metaData: .timeNow, particleGroups: self)
    }
}
