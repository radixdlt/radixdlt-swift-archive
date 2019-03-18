//
//  TokenParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// Bridging Protocol for `BurnedTokensParticle`, `MintedTokensParticle` and `TransferredTokensParticle`
public protocol TokenParticleConvertible:
    ParticleConvertible,
    Ownable,
    Fungible,
    Identifiable,
    RadixCodable,
    RadixModelTypeStaticSpecifying
where
    CodingKeys == TokenParticleCodingKeys {
// swiftlint:enable colon
    
    var address: Address { get }
    var tokenDefinitionIdentifier: TokenDefinitionIdentifier { get }
    var granularity: Granularity { get }
    var planck: Planck { get }
    var nonce: Nonce { get }
    var amount: Amount { get }
    
    init(
        address: Address,
        granularity: Granularity,
        nonce: Nonce,
        planck: Planck,
        amount: Amount,
        tokenDefinitionIdentifier: TokenDefinitionIdentifier
    )
}

public enum TokenParticleCodingKeys: String, CodingKey {
    case type = "serializer"
    case tokenDefinitionIdentifier = "tokenTypeReference"
    case address, granularity, nonce, planck, amount
}

// MARK: Decodable
public extension TokenParticleConvertible {
    // swiftlint:disable:next function_body_length
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
   
        let address = try container.decode(Address.self, forKey: .address)
        let granularity = try container.decode(Granularity.self, forKey: .granularity)
        let nonce = try container.decode(Nonce.self, forKey: .nonce)
        let planck = try container.decode(Planck.self, forKey: .planck)
        let amount = try container.decode(Amount.self, forKey: .amount)
        let tokenDefinitionIdentifier = try container.decode(TokenDefinitionIdentifier.self, forKey: .tokenDefinitionIdentifier)
        
        self.init(
            address: address,
            granularity: granularity,
            nonce: nonce,
            planck: planck,
            amount: amount,
            tokenDefinitionIdentifier: tokenDefinitionIdentifier
        )
    }
}

// MARK: RadixCodable
public extension TokenParticleConvertible {
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
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

// MARK: - Identifiable
public extension TokenParticleConvertible {
    var identifier: ResourceIdentifier {
        return tokenDefinitionIdentifier.identifier
    }
}

// MARK: - Ownable
public extension TokenParticleConvertible {
    var owner: PublicKey {
        return address.publicKey
    }
}
