//
//  SpunParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SpunParticle: Codable {
    public let particle: ParticleConvertible
    public let spin: Spin
}

// MARK: - Codable
public extension SpunParticle {
    
    public enum CodingKeys: CodingKey {
        case particle, spin
    }
    
    private enum ParticleTypeKey: String, CodingKey {
        case type = "serializer"
    }
    
    // swiftlint:disable:next function_body_length
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let particleNestedContainer = try container.nestedContainer(keyedBy: ParticleTypeKey.self, forKey: .particle)
        let particleType = try particleNestedContainer.decode(ParticleTypes.self, forKey: .type)
        switch particleType {
        case .feeParticle: particle = try container.decode(FeeParticle.self, forKey: .particle)
        case .messageParticle: particle = try container.decode(MessageParticle.self, forKey: .particle)
        case .ownedTokensParticle: particle = try container.decode(OwnedTokensParticle.self, forKey: .particle)
        case .timestampParticle: particle = try container.decode(TimestampParticle.self, forKey: .particle)
        case .tokenParticle: particle = try container.decode(TokenParticle.self, forKey: .particle)
        case .uniqueParticle: particle = try container.decode(UniqueParticle.self, forKey: .particle)
        }
        spin = try container.decode(Spin.self, forKey: .spin)
    }
    
    // swiftlint:disable:next function_body_length
    func encode(to encoder: Encoder) throws {
        var encoder = encoder.container(keyedBy: CodingKeys.self)
        if let feeParticle = particle as? FeeParticle {
            try encoder.encode(feeParticle, forKey: .particle)
        } else if let messageParticle = particle as? MessageParticle {
            try encoder.encode(messageParticle, forKey: .particle)
        } else if let ownedTokensParticle = particle as? OwnedTokensParticle {
            try encoder.encode(ownedTokensParticle, forKey: .particle)
        } else if let timestampParticle = particle as? TimestampParticle {
            try encoder.encode(timestampParticle, forKey: .particle)
        } else if let tokenParticle = particle as? TokenParticle {
            try encoder.encode(tokenParticle, forKey: .particle)
        } else if let uniqueParticle = particle as? UniqueParticle {
            try encoder.encode(uniqueParticle, forKey: .particle)
        }
        try encoder.encode(spin, forKey: .spin)
    }
}

public extension SpunParticle {
    static func up(particle: ParticleConvertible) -> SpunParticle {
        return SpunParticle(particle: particle, spin: .up)
    }
    
    static func down(particle: ParticleConvertible) -> SpunParticle {
        return SpunParticle(particle: particle, spin: .down)
    }
}
