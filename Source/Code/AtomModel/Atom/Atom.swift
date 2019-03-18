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
    DSONEncodable,
    CBORStreamable,
    ArrayInitializable {
// swiftlint:enable colon
    
    public static let type = RadixModelType.atom
    
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

// MARK: - Encodable
public extension Atom {
    
    public enum CodingKeys: String, CodingKey {
        case type = "serializer"
        case particleGroups
        case signatures
        case metaData
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        particleGroups = try container.decodeIfPresent(ParticleGroups.self, forKey: .particleGroups) ?? []
        signatures = try container.decodeIfPresent(Signatures.self, forKey: .signatures) ?? [:]
        metaData = try container.decode(ChronoMetaData.self, forKey: .metaData)
    }
    
    func keyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        var properties = [EncodableKeyValue<CodingKeys>]()
        if !particleGroups.isEmpty {
            properties.append(EncodableKeyValue(key: .particleGroups, value: particleGroups.particleGroups))
        }
        if !signatures.isEmpty {
            properties.append(EncodableKeyValue(key: .signatures, value: signatures, output: .all))
        }
        
        properties.append(EncodableKeyValue(key: .metaData, value: metaData))
        
        let atomSize = try AnyCBORPropertyListConvertible(keyValues: properties).toDSON().asData.length
        guard atomSize <= Atom.maxSize else {
            throw Error.tooManyBytes(expectedAtMost: Atom.maxSize, butGot: atomSize)
        }
        
        return properties
    }
    
    static func == (lhs: Atom, rhs: Atom) -> Bool {
        return lhs.radixHash == rhs.radixHash
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

// MARK: - ArrayInitializable
public extension Atom {
    public typealias Element = ParticleGroup
    init(elements particleGroups: [Element]) {
        self.init(particleGroups: ParticleGroups(particleGroups: particleGroups))
    }
}

// MARK: - CustomStringConvertible
public extension Atom {
    // TODO implement this when `hid` does not crash
    //    public var description: String {
    //        return "Atom(\(hid))"
    //    }
}

public extension Atom {
    
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

public extension Atom {
    static let maxSize = 60000
    public enum Error: Swift.Error {
        case tooManyBytes(expectedAtMost: Int, butGot: Int)
    }
}
