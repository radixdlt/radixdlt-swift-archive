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
public struct AnySpunParticle:
    RadixModelTypeStaticSpecifying,
    RadixCodable,
    Codable {
// swiftlint:enable colon

    public static let serializer = RadixModelType.spunParticle

    public let spin: Spin
    public let particle: ParticleConvertible
    public init(spin: Spin = .down, particle: ParticleConvertible) {
        self.spin = spin
        self.particle = particle
    }
}

public extension AnySpunParticle {
    func wrapInGroup() -> ParticleGroup {
        return ParticleGroup(spunParticles: [self])
    }
}

// MARK: - Deodable
public extension AnySpunParticle {
    
    enum CodingKeys: String, CodingKey {
        case serializer
        
        case particle, spin
    }
    
    private enum ParticleTypeKey: String, CodingKey {
        case serializer
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        spin = try container.decode(Spin.self, forKey: .spin)

        // Particle
        let particleNestedContainer = try container.nestedContainer(keyedBy: ParticleTypeKey.self, forKey: .particle)
        let particleSerializer = try particleNestedContainer.decode(RadixModelType.self, forKey: .serializer)
        let particleType = try ParticleType(serializer: particleSerializer)
        
        switch particleType {
        case .message:
            particle = try container.decode(MessageParticle.self, forKey: .particle)
        case .transferrable:
            particle = try container.decode(TransferrableTokensParticle.self, forKey: .particle)
        case .unallocated:
            particle = try container.decode(UnallocatedTokensParticle.self, forKey: .particle)
        case .tokenDefinition:
            particle = try container.decode(TokenDefinitionParticle.self, forKey: .particle)
        case .unique:
            particle = try container.decode(UniqueParticle.self, forKey: .particle)
        case .resourceIdentifier:
            particle = try container.decode(ResourceIdentifierParticle.self, forKey: .particle)
        }
    }
}

// MARK: - Encodable
public extension AnySpunParticle {
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        
        let encodableParticle: EncodableKeyValue<CodingKeys>
        if let messageParticle = particle as? MessageParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: messageParticle)
        } else if let tokenDefinitionParticle = particle as? TokenDefinitionParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: tokenDefinitionParticle)
        } else if let transferrableTokensParticle = particle as? TransferrableTokensParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: transferrableTokensParticle)
        } else if let unallocatedTokenParticle = particle as? UnallocatedTokensParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: unallocatedTokenParticle)
        } else if let uniqueParticle = particle as? UniqueParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: uniqueParticle)
        } else if let resourceIdentifierParticle = particle as? ResourceIdentifierParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: resourceIdentifierParticle)
        } else {
            incorrectImplementation("Forgot some particle type")
        }
        
        return [
            EncodableKeyValue(key: .spin, value: spin),
            encodableParticle
        ]
    }
}

public extension AnySpunParticle {
    static func up(particle: ParticleConvertible) -> AnySpunParticle {
        return AnySpunParticle(spin: .up, particle: particle)
    }
    
    static func down(particle: ParticleConvertible) -> AnySpunParticle {
        return AnySpunParticle(spin: .down, particle: particle)
    }
}
