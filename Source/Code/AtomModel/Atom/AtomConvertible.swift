//
//  AtomConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AtomConvertible: RadixHashable, Codable, ExpressibleByArrayLiteral, CustomStringConvertible {
    var particleGroups: ParticleGroups { get }
    var signatures: Signatures { get }
    init(particleGroups: ParticleGroups, signatures: Signatures)
}

public extension AtomConvertible {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    var radixHash: RadixHash {
        return RadixHash(unhashedData: toDson(), hashedBy: Sha256TwiceHasher())
    }
    
    func toDson() -> Data {
        // swiftlint:disable:next force_try
        return try! JSONEncoder().encode(self)
    }
    
    var hid: EUID {
        return radixHash.toEUID()
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension AtomConvertible {
    public init(arrayLiteral particleGroups: ParticleGroup...) {
        self.init(particleGroups: ParticleGroups(particleGroups: particleGroups), signatures: [:])
    }
}

// MARK: - CustomStringConvertible
public extension AtomConvertible {
    public var description: String {
        return "Atom(\(hid))"
    }
}

public extension AtomConvertible {
    
    func spunParticles() -> [SpunParticle] {
        return particleGroups.flatMap { $0.spunParticles }
    }
    
    func dataParticles() -> [MessageParticle] {
        return spunParticles().compactMap(type: MessageParticle.self)
    }
    
    func consumables(spin: Spin) -> [OwnedTokensParticle] {
        return spunParticles()
            .filter(spin: spin)
            .compactMap(type: OwnedTokensParticle.self)
    }
    
    func timestamp() -> Date? {
        return spunParticles().compactMap(type: TimestampParticle.self).first?.timestamp()
    }
    
    func publicKeys() -> Set<PublicKey> {
        return spunParticles()
            .map { $0.particle }
            .flatMap { Array($0.publicKeys()) }
            .asSet
    }
}
