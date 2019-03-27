//
//  ParticleGroup.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon
/// Grouping of Particles relating to each other also holding some metadata
public struct ParticleGroup:
    RadixCodable,
    ArrayConvertible,
    RadixModelTypeStaticSpecifying {
 // swiftlint:enable colon
    public static let type = RadixModelType.particleGroup
    
    public let spunParticles: [SpunParticle]
    public let metaData: MetaData
    
    public init(
        spunParticles: [SpunParticle],
        metaData: MetaData = [:]
    ) {
        self.spunParticles = spunParticles
        self.metaData = metaData
    }
}

// MARK: - Codable
public extension ParticleGroup {
    enum CodingKeys: String, CodingKey {
        case type = "serializer"
        
        case spunParticles = "particles"
        case metaData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        spunParticles = try container.decode([SpunParticle].self, forKey: .spunParticles)
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
    typealias Element = SpunParticle
    var elements: [Element] {
        return spunParticles
    }
    init(elements: [Element]) {
        self.init(spunParticles: elements)
    }
}
