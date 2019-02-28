//
//  TokenParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenParticle: ParticleConvertible, Ownable, Fungible, Identifiable {

    public let type: ParticleTypes
    
    public let owner: PublicKey
    public let receiver: Address
    public let nonce: Nonce
    public let planck: Planck
    public let amount: Amount
    public let tokenDefinitionIdentifier: TokenDefinitionIdentifier
}

// MARK: - Identifiable
public extension TokenParticle {
    var identifier: ResourceIdentifier {
        return tokenDefinitionIdentifier.identifier
    }
}

// MARK: - Public
public extension TokenParticle {
    public var tokenType: TokenType {
        do {
            return try TokenType(particleType: type)
        } catch {
            incorrectImplementation("Should always be possible to get TokenType")
        }
    }
}

// MARK: Decodable
public extension TokenParticle {
    public enum CodingKeys: String, CodingKey {
        case tokenDefinitionIdentifier = "token_reference"
        case type, owner, receiver, nonce, planck, amount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try container.decode(ParticleTypes.self, forKey: .type)
        owner = try container.decode(PublicKey.self, forKey: .owner)
        receiver = try container.decode(Address.self, forKey: .receiver)
        nonce = try container.decode(Nonce.self, forKey: .nonce)
        planck = try container.decode(Planck.self, forKey: .planck)
        amount = try container.decode(Amount.self, forKey: .amount)
        tokenDefinitionIdentifier = try container.decode(TokenDefinitionIdentifier.self, forKey: .tokenDefinitionIdentifier)
    }
}
