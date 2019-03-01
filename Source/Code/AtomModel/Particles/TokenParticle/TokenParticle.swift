//
//  TokenParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenParticle: ParticleConvertible, Ownable, Fungible, Identifiable, RadixModelTypeSpecifying {

    public let type: RadixModelType
    public let tokenType: TokenType
    
    public let owner: PublicKey
    public let receiver: Address
    public let nonce: Nonce
    public let planck: Planck
    public let amount: Amount
    public let tokenDefinitionIdentifier: TokenDefinitionIdentifier
    
    public init(
        type: TokenType,
        owner: PublicKey,
        receiver: Address,
        nonce: Nonce = Nonce(),
        planck: Planck = Planck(),
        amount: Amount,
        tokenDefinitionIdentifier: TokenDefinitionIdentifier
        ) {
        self.type = type.particleType.modelType
        self.tokenType = type
        self.owner = owner
        self.receiver = receiver
        self.nonce = nonce
        self.planck = planck
        self.amount = amount
        self.tokenDefinitionIdentifier = tokenDefinitionIdentifier
    }
}

// MARK: - ParticleConvertible
public extension TokenParticle {
    var particleType: ParticleType {
        return tokenType.particleType
    }
}

// MARK: - Identifiable
public extension TokenParticle {
    var identifier: ResourceIdentifier {
        return tokenDefinitionIdentifier.identifier
    }
}

// MARK: Decodable
public extension TokenParticle {
    public enum CodingKeys: String, CodingKey {
        case type = "serializer"
        case tokenDefinitionIdentifier = "token_reference"
        case owner, receiver, nonce, planck, amount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let modelType = try container.decode(RadixModelType.self, forKey: .type)
        type = modelType
        tokenType = try TokenType(modelType: modelType)
        owner = try container.decode(PublicKey.self, forKey: .owner)
        receiver = try container.decode(Address.self, forKey: .receiver)
        nonce = try container.decode(Nonce.self, forKey: .nonce)
        planck = try container.decode(Planck.self, forKey: .planck)
        amount = try container.decode(Amount.self, forKey: .amount)
        tokenDefinitionIdentifier = try container.decode(TokenDefinitionIdentifier.self, forKey: .tokenDefinitionIdentifier)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        try container.encode(owner, forKey: .owner)
        try container.encode(receiver, forKey: .receiver)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(planck, forKey: .planck)
        try container.encode(tokenDefinitionIdentifier, forKey: .tokenDefinitionIdentifier)
        try container.encode(amount, forKey: .amount)
    }
}
