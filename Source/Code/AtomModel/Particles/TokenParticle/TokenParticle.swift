//
//  TokenParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenParticle: ParticleConvertible, Ownable, Fungible, Identifiable, CBORStreamable, RadixModelTypeSpecifying {

    public let type: RadixModelType
    public let tokenType: TokenType
    
    public let address: Address
    public let tokenDefinitionIdentifier: TokenDefinitionIdentifier
    public let granularity: Granularity
    public let planck: Planck
    public let nonce: Nonce
    public let amount: Amount
    
    public init(
        type: TokenType,
        address: Address,
        granularity: Granularity,
        nonce: Nonce = Nonce(),
        planck: Planck = Planck(),
        amount: Amount,
        tokenDefinitionIdentifier: TokenDefinitionIdentifier
        ) {
        self.type = type.particleType.modelType
        self.tokenType = type
        self.address = address
        self.granularity = granularity
        self.nonce = nonce
        self.planck = planck
        self.amount = amount
        self.tokenDefinitionIdentifier = tokenDefinitionIdentifier
    }
}

// MARK: - Identifiable
public extension TokenParticle {
    var identifier: ResourceIdentifier {
        return tokenDefinitionIdentifier.identifier
    }
}

// MARK: - Ownable
public extension TokenParticle {
    var owner: PublicKey {
        return address.publicKey
    }
}

// MARK: Decodable
public extension TokenParticle {
    public enum CodingKeys: String, CodingKey {
        case type = "serializer"
        case tokenDefinitionIdentifier = "tokenTypeReference"
        case address, granularity, nonce, planck, amount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let modelType = try container.decode(RadixModelType.self, forKey: .type)
        type = modelType
        tokenType = try TokenType(modelType: modelType)
        address = try container.decode(Address.self, forKey: .address)
        granularity = try container.decode(Granularity.self, forKey: .granularity)
        nonce = try container.decode(Nonce.self, forKey: .nonce)
        planck = try container.decode(Planck.self, forKey: .planck)
        amount = try container.decode(Amount.self, forKey: .amount)
        tokenDefinitionIdentifier = try container.decode(TokenDefinitionIdentifier.self, forKey: .tokenDefinitionIdentifier)
    }
 
    func keyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .address, value: address),
            EncodableKeyValue(key: .granularity, value: granularity),
            EncodableKeyValue(key: .nonce, value: nonce),
            EncodableKeyValue(key: .planck, value: planck),
            EncodableKeyValue(key: .tokenDefinitionIdentifier, value: tokenDefinitionIdentifier.identifier),
            EncodableKeyValue(key: .amount, value: amount)
        ]
    }
}
