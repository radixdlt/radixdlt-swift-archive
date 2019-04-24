//
//  UnallocatedTokensParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

public struct UnallocatedTokensParticle:
    ParticleConvertible,
    RadixCodable,
    RadixModelTypeStaticSpecifying,
    TokenDefinitionReferencing {
    // swiftlint:enable colon
    public static let serializer = RadixModelType.unallocatedTokensParticle
    
    public let tokenDefinitionReference: ResourceIdentifier
    public let granularity: Granularity
    public let nonce: Nonce
    public let amount: PositiveAmount
    public let permissions: TokenPermissions
    
    public init(
        amount: PositiveAmount,
        tokenDefinitionReference: ResourceIdentifier,
        permissions: TokenPermissions = .default,
        granularity: Granularity = .default,
        nonce: Nonce = Nonce()
        ) {
        self.granularity = granularity
        self.nonce = nonce
        self.amount = amount
        self.tokenDefinitionReference = tokenDefinitionReference
        self.permissions = permissions
    }
}

// MARK: - From TokenDefinitionParticle
public extension UnallocatedTokensParticle {
    init(
        token: TokenDefinitionParticle,
        amount: PositiveAmount) {
        self.init(
            amount: amount,
            tokenDefinitionReference: token.tokenDefinitionReference,
            permissions: token.permissions,
            granularity: token.granularity
        )
    }
}

// MARK: Decodable
public extension UnallocatedTokensParticle {
    
    enum CodingKeys: String, CodingKey {
        case serializer
        case tokenDefinitionReference
        case granularity, nonce, amount, permissions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let granularity = try container.decode(Granularity.self, forKey: .granularity)
        let nonce = try container.decode(Nonce.self, forKey: .nonce)
        let amount = try container.decode(PositiveAmount.self, forKey: .amount)
        let permissions = try container.decode(TokenPermissions.self, forKey: .permissions)
        let tokenDefinitionReference = try container.decode(ResourceIdentifier.self, forKey: .tokenDefinitionReference)
        
        self.init(
            amount: amount,
            tokenDefinitionReference: tokenDefinitionReference,
            permissions: permissions,
            granularity: granularity,
            nonce: nonce
        )
    }
}

// MARK: RadixCodable
public extension UnallocatedTokensParticle {
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .permissions, value: permissions),
            EncodableKeyValue(key: .granularity, value: granularity),
            EncodableKeyValue(key: .nonce, value: nonce),
            EncodableKeyValue(key: .tokenDefinitionReference, value: tokenDefinitionReference),
            EncodableKeyValue(key: .amount, value: amount)
        ]
    }
}
