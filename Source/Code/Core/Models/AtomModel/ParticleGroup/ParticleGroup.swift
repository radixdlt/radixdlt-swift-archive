//
//  ParticleGroup.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension ParticleConvertible {
    func withSpin(_ spin: Spin = .up) -> AnySpunParticle {
        return AnySpunParticle(spin: spin, particle: self)
    }
}

// swiftlint:disable colon
/// Grouping of Particles relating to each other also holding some metadata
public struct ParticleGroup:
    RadixCodable,
    ArrayConvertible,
    ArrayInitializable,
    RadixModelTypeStaticSpecifying,
    Codable {
 // swiftlint:enable colon
    public static let serializer = RadixModelType.particleGroup
    
    public let spunParticles: [AnySpunParticle]
    public let metaData: MetaData
    
    public init(
        spunParticles: [AnySpunParticle],
        metaData: MetaData = [:]
    ) {
        self.spunParticles = spunParticles
        self.metaData = metaData
    }
}

// MARK: - Codable
public extension ParticleGroup {
    enum CodingKeys: String, CodingKey {
        case serializer
        
        case spunParticles = "particles"
        case metaData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        spunParticles = try container.decode([AnySpunParticle].self, forKey: .spunParticles)
        metaData = try container.decodeIfPresent(MetaData.self, forKey: .metaData) ?? [:]
    }
        
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        var properties = [EncodableKeyValue<CodingKeys>]()
        if !spunParticles.isEmpty {
            properties.append(EncodableKeyValue(key: .spunParticles, value: spunParticles))
        }
        
        if !metaData.isEmpty {
            properties.append(EncodableKeyValue(key: .metaData, value: metaData))
        }
        
        return properties
    }
}

// MARK: - ArrayDecodable
public extension ParticleGroup {
    typealias Element = AnySpunParticle
    var elements: [Element] {
        return spunParticles
    }
    init(elements: [Element]) {
        self.init(spunParticles: elements)
    }
}
