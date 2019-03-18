//
//  AtomConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AtomConvertible: RadixModelTypeStaticSpecifying, RadixHashable, DSONEncodable, ExpressibleByArrayLiteral {
    var particleGroups: ParticleGroups { get }
    var signatures: Signatures { get }
    var metaData: ChronoMetaData { get }
    init(metaData: ChronoMetaData, signatures: Signatures, particleGroups: ParticleGroups)
}

public extension AtomConvertible {
    
    init(
        metaData: ChronoMetaData = .timeNow,
        signatures: Signatures = [:],
        particleGroups: ParticleGroups = []) {
        self.init(metaData: metaData, signatures: signatures, particleGroups: particleGroups)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    var radixHash: RadixHash {
        do {
            return RadixHash(unhashedData: try toDSON(output: .hash), hashedBy: Sha256TwiceHasher())
        } catch {
            incorrectImplementation("Should always be able to hash, error: \(error)")
        }
    }
    
    var hid: EUID {
        return radixHash.toEUID()
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension AtomConvertible {
    public init(arrayLiteral particleGroups: ParticleGroup...) {
        self.init(particleGroups: ParticleGroups(particleGroups: particleGroups))
    }
}

// MARK: - CustomStringConvertible
public extension AtomConvertible {
    // TODO implement this when `hid` does not crash
//    public var description: String {
//        return "Atom(\(hid))"
//    }
}

public extension AtomConvertible {
    
    func spunParticles() -> [SpunParticle] {
        return particleGroups.flatMap { $0.spunParticles }
    }
    
    func messageParticles() -> [MessageParticle] {
        return spunParticles().compactMap(type: MessageParticle.self)
    }
    
    func tokensParticles(spin: Spin, type: TokenType? = nil) -> [TokenParticle] {
        let tokenParticles = spunParticles()
            .filter(spin: spin)
            .compactMap(type: TokenParticle.self)
        guard let type = type else {
            return tokenParticles
        }
        return tokenParticles.filter(type: type)
    }
    
    var timestamp: Date? {
        return metaData.timestamp
    }
    
    func publicKeys() -> Set<PublicKey> {
        return spunParticles()
            .map { $0.particle }
            .flatMap { Array($0.keyDestinations()) }
            .asSet
    }
}
