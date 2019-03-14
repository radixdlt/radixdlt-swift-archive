//
//  Atom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Atom
public struct Atom: AtomConvertible, CBORStreamable {
    
    public static let type = RadixModelType.atom
    
    public let particleGroups: ParticleGroups
    public let signatures: Signatures
    public let metaData: MetaData
    
    public init(
        particleGroups: ParticleGroups = [],
        signatures: Signatures = [:],
        metaData: MetaData = [:]
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
        particleGroups = try container.decode(ParticleGroups.self, forKey: .particleGroups)
        signatures = try container.decodeIfPresent(Signatures.self, forKey: .signatures) ?? [:]
        metaData = try container.decodeIfPresent(MetaData.self, forKey: .metaData) ?? [:]
    }
    
    // swiftlint:disable:next function_body_length
    func keyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        var properties = [EncodableKeyValue<CodingKeys>]()
        if !particleGroups.isEmpty {
            properties.append(EncodableKeyValue(key: .particleGroups, value: particleGroups.particleGroups))
        }
        if !signatures.isEmpty {
            properties.append(EncodableKeyValue(key: .signatures, value: signatures))
        }
        if !metaData.isEmpty {
            properties.append(EncodableKeyValue(key: .metaData, value: metaData))
        }
        
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
