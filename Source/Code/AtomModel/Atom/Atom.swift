//
//  Atom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Atom
public struct Atom: AtomConvertible {
    
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
        signatures = try container.decode(Signatures.self, forKey: .signatures)
        metaData = try container.decode(MetaData.self, forKey: .metaData)
    }
    
    // swiftlint:disable:next function_body_length
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Atom.CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        try container.encode(particleGroups, forKey: .particleGroups)
        try container.encode(signatures, forKey: .signatures)
        try container.encode(metaData, forKey: .metaData)

        let enc = Foundation.JSONEncoder()
        let atomSize = [
            try enc.encode(particleGroups),
            try enc.encode(signatures),
            try enc.encode(metaData)
        ].map { $0.length }.reduce(0, +)
        
        guard atomSize <= Atom.maxSize else {
            throw Error.tooManyBytes(expectedAtMost: Atom.maxSize, butGot: atomSize)
        }
    }
}

public extension Atom {
    static let maxSize = 60000
    public enum Error: Swift.Error {
        case tooManyBytes(expectedAtMost: Int, butGot: Int)
    }
}
