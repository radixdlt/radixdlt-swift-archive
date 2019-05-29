//
//  Atomic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol Atomic: RadixModelTypeStaticSpecifying {
    var particleGroups: ParticleGroups { get }
    var signatures: Signatures { get }
    var metaData: ChronoMetaData { get }
    func identifier() -> AtomIdentifier
}

// MARK: - RadixModelTypeStaticSpecifying
public extension Atomic {
    static var serializer: RadixModelType {
        return .atom
    }
}

public extension Atomic {
    
    /// Shard of each destination address of this atom
    /// This set ought to never be empty
    func shards() throws -> Shards {
        let shards = spunParticles()
            .map { $0.particle }
            .compactMap { $0.shardables() }
            .flatMap { $0 }
            .map { $0.publicKey.shard }
        
        return try Shards(set: shards.asSet)
    }
}

public extension Atomic where Self: RadixHashable {
    
    func identifier() -> AtomIdentifier {
        do {
            return try AtomIdentifier(hash: radixHash, shards: try shards())
        } catch {
            incorrectImplementation("Failed to create AtomIdentifier, error: \(error)")
        }
    }
    
    // MARK: Equatable
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.radixHash == rhs.radixHash
    }
    
    // MARK: - CustomStringConvertible
    var description: String {
        return "Atom(\(hashId))"
    }
    
    // MARK: - CustomDebugStringConvertible
    var debugDescription: String {
        return "Atom(\(hashId), pg#\(particleGroups.count), p#\(spunParticles().count), md#\(metaData.count), s#\(signatures.count))"
    }
    
    var signable: Signable {
        return Message(hash: radixHash)
    }
}

public extension Atomic {
    
    func spunParticles() -> [AnySpunParticle] {
        return particleGroups.flatMap { $0.spunParticles }
    }
    
    func particles() -> [ParticleConvertible] {
        return spunParticles().map { $0.particle }
    }
    
    func messageParticles() -> [MessageParticle] {
        return spunParticles().compactMap(type: MessageParticle.self)
    }
    
    func tokensBalances() -> [TokenBalance] {
        return spunParticles().compactMap {
            $0.mapToSpunParticle(with: TransferrableTokensParticle.self)
        }.map {
            TokenBalance(spunTransferrable: $0)
        }
    }
    
    func particlesOfType<P>(_ type: P.Type, spin: Spin? = nil) -> [P] where P: ParticleConvertible {
        return spunParticles()
            .filter(spin: spin)
            .compactMap(type: P.self)
    }
    
    func particles(spin: Spin) -> [ParticleConvertible] {
        return spunParticles()
            .filter(spin: spin)
            .map { $0.particle }
    }
    
    var timestamp: Date? {
        return metaData.timestamp
    }
}
