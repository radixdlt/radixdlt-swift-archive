//
//  SpunParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// Small container for a `Particle` and its `Spin`. The reason why we do not want to add the `Spin` as a property on the Particle itself is that it would change the Hash of the particle.
public struct SpunParticle:
    RadixModelTypeStaticSpecifying,
    RadixCodable,
    Codable {
// swiftlint:enable colon

    public static let type = RadixModelType.spunParticle

    public let spin: Spin
    public let particle: ParticleConvertible
    public init(spin: Spin = .down, particle: ParticleConvertible) {
        self.spin = spin
        self.particle = particle
    }
}

// MARK: - Deodable
public extension SpunParticle {
    
    public enum CodingKeys: String, CodingKey {
        case type = "serializer"
        
        case particle, spin
    }
    
    private enum ParticleTypeKey: String, CodingKey {
        case type = "serializer"
    }
    
    // swiftlint:disable:next function_body_length
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let particleNestedContainer = try container.nestedContainer(keyedBy: ParticleTypeKey.self, forKey: .particle)
        let modelType = try particleNestedContainer.decode(RadixModelType.self, forKey: .type)
        let particleType = try ParticleType(modelType: modelType)
        switch particleType {
        case .message:
            particle = try container.decode(MessageParticle.self, forKey: .particle)
        case .burnedToken, .transferredToken, .mintedToken:
            particle = try container.decode(TokenParticle.self, forKey: .particle)
        case .tokenDefinition: particle = try container.decode(TokenDefinitionParticle.self, forKey: .particle)
        case .unique: particle = try container.decode(UniqueParticle.self, forKey: .particle)
        }
        spin = try container.decode(Spin.self, forKey: .spin)
    }
}

// MARK: - Encodable
public extension SpunParticle {
    
    // swiftlint:disable:next function_body_length
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        
        let encodableParticle: EncodableKeyValue<CodingKeys>
        if let messageParticle = particle as? MessageParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: messageParticle)
        } else if let tokenDefinitionParticle = particle as? TokenDefinitionParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: tokenDefinitionParticle)
        } else if let tokenParticle = particle as? TokenParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: tokenParticle)
        } else if let uniqueParticle = particle as? UniqueParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: uniqueParticle)
        } else {
            incorrectImplementation("Forgot some particle type")
        }
        
        return [
            EncodableKeyValue(key: .spin, value: spin),
            encodableParticle
        ]
    }
}

public extension SpunParticle {
    static func up(particle: ParticleConvertible) -> SpunParticle {
        return SpunParticle(spin: .up, particle: particle)
    }
    
    static func down(particle: ParticleConvertible) -> SpunParticle {
        return SpunParticle(spin: .down, particle: particle)
    }
    
    func particle<P>(as type: P.Type) -> P? where P: ParticleConvertible {
        return particle.as(P.self)
    }
}
