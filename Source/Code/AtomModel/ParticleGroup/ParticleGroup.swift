//
//  ParticleGroup.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable:next colon
public struct ParticleGroup:
    CBORStreamable,
    ArrayConvertible,
    RadixModelTypeStaticSpecifying {
    
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
    public enum CodingKeys: String, CodingKey {
        case type = "serializer"
        
        case spunParticles = "particles"
        case metaData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        spunParticles = try container.decode([SpunParticle].self, forKey: .spunParticles)
        metaData = try container.decodeIfPresent(MetaData.self, forKey: .metaData) ?? [:]
    }
        
    public func keyValues() throws -> [EncodableKeyValue<CodingKeys>] {
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
    public typealias Element = SpunParticle
    var elements: [Element] {
        return spunParticles
    }
    init(elements: [Element]) {
        self.init(spunParticles: elements)
    }
}
