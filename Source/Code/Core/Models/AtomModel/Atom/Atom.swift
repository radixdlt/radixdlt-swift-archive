//
//  Atom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon
/// The packaging of any transaction to the Radix Ledger, the Atom is the highest level model in the [Atom Model][1], consisting of a list of ParticleGroups, which in turn consists of a list of SpunParticles and metadata.
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/404029477/RIP-1+The+Atom+Model
/// - seeAlso:
/// `ParticleGroup`
///
public struct Atom:
    RadixModelTypeStaticSpecifying,
    RadixHashable,
    RadixCodable,
    SignableConvertible,
    ArrayInitializable,
    Codable,
    Hashable,
    CustomStringConvertible,
    CustomDebugStringConvertible {
// swiftlint:enable colon
    
    public static let serializer = RadixModelType.atom
    
    public let particleGroups: ParticleGroups
    public let signatures: Signatures
    public let metaData: ChronoMetaData
    
    public init(
        metaData: ChronoMetaData = .timeNow,
        signatures: Signatures = [:],
        particleGroups: ParticleGroups = []
    ) {
        self.particleGroups = particleGroups
        self.signatures = signatures
        self.metaData = metaData
    }
}

public extension ParticleConvertible {
    func wrapInAtom(spin: Spin = .up, magic: Magic) throws -> Atom {
        let atom = Atom(particle: self)
        let hash = atom.radixHash
        let proofOfWork = try ProofOfWork.work(seed: hash.asData, magic: magic)
        return atom.withProofOfWork(proofOfWork)
    }
}

public extension MetaDataConvertible {
    func withProofOfWork(_ proof: ProofOfWork) -> Self {
        return inserting(value: proof.nonceAsString, forKey: .proofOfWork)
    }
}

// MARK: - Convenience Init
public extension Atom {
    
    func withProofOfWork(magic: Magic) throws -> Atom {
        let pow = try ProofOfWork.work(atom: self, magic: magic)
        return withProofOfWork(pow)
    }
    
    func withProofOfWork(_ proof: ProofOfWork) -> Atom {
        let atom = Atom(
            metaData: metaData.withProofOfWork(proof),
            signatures: signatures,
            particleGroups: particleGroups
        )
        return atom
    }
    
    init(particle: ParticleConvertible, spin: Spin = .up) {
        self.init(
            particleGroups: [
                ParticleGroup(
                    spunParticles: [
                        SpunParticle(spin: spin, particle: particle)
                    ]
                )
            ]
        )
    }
}

// MARK: - Encodable
public extension Atom {
    
    enum CodingKeys: String, CodingKey {
        case serializer
        case particleGroups
        case signatures
        case metaData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        particleGroups = try container.decodeIfPresent(ParticleGroups.self, forKey: .particleGroups) ?? []
        signatures = try container.decodeIfPresent(Signatures.self, forKey: .signatures) ?? [:]
        metaData = try container.decode(ChronoMetaData.self, forKey: .metaData)
    }
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        let properties = [
            EncodableKeyValue<CodingKeys>(key: .metaData, value: metaData),
            EncodableKeyValue(key: .particleGroups, nonEmpty: particleGroups.particleGroups),
            EncodableKeyValue(key: .signatures, nonEmpty: signatures, output: [.api, .wire, .persist])
        ].compactMap { $0 }

        let atomSize = try AnyEncodableKeyValueList(keyValues: properties).toDSON().asData.length
        
        guard atomSize <= Atom.maxSize else {
            throw Error.tooManyBytes(expectedAtMost: Atom.maxSize, butGot: atomSize)
        }
        
        return properties
    }
        
    static func == (lhs: Atom, rhs: Atom) -> Bool {
        return lhs.radixHash == rhs.radixHash
    }
}

// MARK: - ArrayInitializable
public extension Atom {
    typealias Element = ParticleGroup
    init(elements particleGroups: [Element]) {
        self.init(particleGroups: ParticleGroups(particleGroups: particleGroups))
    }
}

// MARK: - CustomStringConvertible
public extension Atom {
    var description: String {
        return "Atom(\(hashId))"
    }
}

// MARK: - CustomDebugStringConvertible
public extension Atom {
    var debugDescription: String {
        return "Atom(\(hashId), pg#\(particleGroups.count), p#\(spunParticles().count), md#\(metaData.count), s#\(signatures.count))"
    }
}

public extension Atom {
    
    func spunParticles() -> [SpunParticle] {
        return particleGroups.flatMap { $0.spunParticles }
    }
    
    func particles() -> [ParticleConvertible] {
        return spunParticles().map { $0.particle }
    }
    
    func messageParticles() -> [MessageParticle] {
        return spunParticles().compactMap(type: MessageParticle.self)
    }
    
    func tokensBalances() -> [TokenBalance] {
        let tokenBalances = spunParticles().compactMap { (spunParticle: SpunParticle) -> TokenBalance? in
            guard let consumable = spunParticle.particle as? ConsumableTokens else {
                return nil
            }
            return TokenBalance(consumable: consumable, spin: spunParticle.spin)
        }
        return tokenBalances
    }
    
    func particlesOfType<P>(_ type: P.Type, spin: Spin) -> [P] where P: ParticleConvertible {
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
    
    func withSignature(_ signature: Signature, signatureId: EUID) -> SignedAtom {
        let atom = Atom(
            metaData: metaData,
            signatures: signatures.inserting(value: signature, forKey: signatureId),
            particleGroups: particleGroups
        )
        do {
            return try SignedAtom(atom: atom, signatureId: signatureId)
        } catch {
            incorrectImplementation("Should always be able to create SignedAtom")
        }
    }
    
    var signable: Signable {
        return Message(hash: radixHash)
    }
}

public extension Atom {
    static let maxSize = 60000
    enum Error: Swift.Error {
        case tooManyBytes(expectedAtMost: Int, butGot: Int)
    }
}
