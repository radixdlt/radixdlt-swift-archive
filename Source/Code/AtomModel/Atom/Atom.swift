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
    AtomConvertible,
    CBORStreamable {
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
}

public extension Atom {
    static let maxSize = 60000
    public enum Error: Swift.Error {
        case tooManyBytes(expectedAtMost: Int, butGot: Int)
    }
}
