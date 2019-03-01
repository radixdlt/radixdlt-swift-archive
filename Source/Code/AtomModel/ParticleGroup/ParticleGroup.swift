//
//  ParticleGroup.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
public struct ParticleGroup: ArrayCodable, RadixModelTypeStaticSpecifying {
    
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
        metaData = try container.decode(MetaData.self, forKey: .metaData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(spunParticles, forKey: .spunParticles)
        try container.encode(metaData, forKey: .metaData)
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
