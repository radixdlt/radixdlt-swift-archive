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
    TokenDefinitionReferencing,
    Accountable,
    RadixCodable,
    RadixModelTypeStaticSpecifying
where
    CodingKeys == TokenParticleCodingKeys {
// swiftlint:enable colon
    
    var address: Address { get }
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
        tokenDefinitionReference: TokenDefinitionReference
    )
}

public extension TokenParticleConvertible {
    init(
        address: Address,
        granularity: Granularity = .default,
        nonce: Nonce = Nonce(),
        planck: Planck = Planck(),
        amount: Amount,
        tokenDefinitionReference: TokenDefinitionReference
    ) {
        
        self.init(
            address: address,
            granularity: granularity,
            nonce: nonce,
            planck: planck,
            amount: amount,
            tokenDefinitionReference: tokenDefinitionReference
        )
    }
}

public enum TokenParticleCodingKeys: String, CodingKey {
    case serializer
    case tokenDefinitionReference
    case address, granularity, nonce, planck, amount
}

// MARK: Decodable
public extension TokenParticleConvertible {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
   
        let address = try container.decode(Address.self, forKey: .address)
        let granularity = try container.decode(Granularity.self, forKey: .granularity)
        let nonce = try container.decode(Nonce.self, forKey: .nonce)
        let planck = try container.decode(Planck.self, forKey: .planck)
        let amount = try container.decode(Amount.self, forKey: .amount)
        let tokenDefinitionReference = try container.decode(TokenDefinitionReference.self, forKey: .tokenDefinitionReference)
        
        self.init(
            address: address,
            granularity: granularity,
            nonce: nonce,
            planck: planck,
            amount: amount,
            tokenDefinitionReference: tokenDefinitionReference
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
            EncodableKeyValue(key: .tokenDefinitionReference, value: identifier),
            EncodableKeyValue(key: .amount, value: amount)
        ]
    }
}

// MARK: - Ownable
public extension TokenParticleConvertible {
    var publicKey: PublicKey {
        return address.publicKey
    }
}

// MARK: Accountable
public extension TokenParticleConvertible {
    var addresses: Addresses {
        return Addresses(arrayLiteral: address)
    }
}

public extension TokenParticleConvertible {
    init(
        address: Address,
        granularity: Granularity = .default,
        nonce: Nonce = Nonce(),
        planck: Planck = Planck(),
        amount: Amount,
        symbol: Symbol,
        tokenAddress: Address? = nil
        ) {
        
        let tokenDefinitionReference = TokenDefinitionReference(
            address: tokenAddress ?? address,
            symbol: symbol
        )
        
        self.init(
            address: address,
            granularity: granularity,
            nonce: nonce,
            planck: planck,
            amount: amount,
            tokenDefinitionReference: tokenDefinitionReference
        )
    }
}
