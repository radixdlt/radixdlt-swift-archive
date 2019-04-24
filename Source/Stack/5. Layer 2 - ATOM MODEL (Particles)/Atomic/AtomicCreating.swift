//
//  AtomicCreating.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public protocol AtomicCreating:
    ArrayInitializable,
    Throwing,
    RadixHashable,
    RadixCodable,
    SignableConvertible,
    CustomStringConvertible,
    CustomDebugStringConvertible,
    Codable,
    Hashable
where
    Element == ParticleGroup,
    CodingKeys == AtomCodingKeys,
    Error == AtomError
{
    // swiftlint:enable colon opening_brace

    init(
        metaData: ChronoMetaData,
        signatures: Signatures,
        particleGroups: ParticleGroups
    )
}

public extension AtomicCreating {
    init(atomic: Atomic) {
        self.init(
            metaData: atomic.metaData,
            signatures: atomic.signatures,
            particleGroups: atomic.particleGroups
        )
    }
}

// MARK: - AtomCodingKeys
public enum AtomCodingKeys: String, CodingKey {
    case serializer
    case particleGroups
    case signatures
    case metaData
}

// MARK: - Throwing
public enum AtomError: Swift.Error {
    case tooManyBytes(expectedAtMost: Int, butGot: Int)
}

// MARK: - Decodable
public extension AtomicCreating {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let metaData = try container.decode(ChronoMetaData.self, forKey: .metaData)
        
        let signatures = try container.decodeIfPresent(Signatures.self, forKey: .signatures) ?? [:]
        
        let particleGroups = try container.decodeIfPresent(ParticleGroups.self, forKey: .particleGroups) ?? []
        
        self.init(
            metaData: metaData,
            signatures: signatures,
            particleGroups: particleGroups
        )
    }
}
public extension AtomicCreating where Self: Atomic {
    // MARK: - Encodable
    static var maxSizeOfDSONEncodedAtomInBytes: Int {
        return 60000
    }
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        let properties = [
            EncodableKeyValue<CodingKeys>(key: .metaData, value: metaData),
            EncodableKeyValue(key: .particleGroups, nonEmpty: particleGroups.particleGroups),
            EncodableKeyValue(key: .signatures, nonEmpty: signatures, output: .allButHash)
        ].compactMap { $0 }
        
        let atomSize = try AnyEncodableKeyValueList(keyValues: properties).toDSON().asData.length
        
        guard atomSize <= Self.maxSizeOfDSONEncodedAtomInBytes else {
            throw Error.tooManyBytes(expectedAtMost: Self.maxSizeOfDSONEncodedAtomInBytes, butGot: atomSize)
        }
        
        return properties
    }
}

// MARK: - ArrayInitializable
public extension AtomicCreating {
    init(elements particleGroups: [Element]) {
        self.init(particleGroups: ParticleGroups(particleGroups: particleGroups))
    }
}

// MARK: - Convenience
public extension AtomicCreating {
    init(
        metaData: ChronoMetaData = .timeNow,
        signatures: Signatures = [:],
        particleGroups: ParticleGroups = []
        ) {
        self.init(metaData: metaData, signatures: signatures, particleGroups: particleGroups)
    }
    
    init(particle: ParticleConvertible, spin: Spin = .up) {
        self.init(
            particleGroups: [
                ParticleGroup(
                    spunParticles: [
                        AnySpunParticle(spin: spin, particle: particle)
                    ]
                )
            ]
        )
    }
}
