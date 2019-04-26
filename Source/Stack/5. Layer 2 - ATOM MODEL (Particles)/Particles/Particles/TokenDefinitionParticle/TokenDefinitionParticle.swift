//
//  TokenDefinitionParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// For every new kind of Token, a Token Definition must be submitted that describes what the token is (e.g. its name) and how it should behave (e.g. only owner can mint tokens).
///
/// The specified properties - both general information about the Token and constraints on its use (e.g. only owner can mint tokens) are included in the Token Particle.
/// For the formal definition read [RIP - Tokens][1].
///
/// - seeAlso:
/// `TokenDefinitionParticle`
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/407241467/RIP-2+Tokens
///
public struct TokenDefinitionParticle:
    ParticleConvertible,
    RadixModelTypeStaticSpecifying,
    TokenConvertible,
    RadixCodable,
    RadixHashable,
    DSONEncodable,
    Hashable {
// swiftlint:enable colon
    
    public static let serializer = RadixModelType.tokenDefinitionParticle
    
    public let symbol: Symbol
    public let name: Name
    public let description: Description
    public let address: Address
    public let granularity: Granularity
    public let permissions: TokenPermissions
    public let icon: Data?
    
    public init(
        symbol: Symbol,
        name: Name,
        description: Description,
        address: Address,
        granularity: Granularity = .default,
        permissions: TokenPermissions = .default,
        icon: Data? = nil
    ) {
        self.symbol = symbol
        self.name = name
        self.description = description
        self.address = address
        self.granularity = granularity
        self.permissions = permissions
        self.icon = icon
    }
}

// MARK: - Hashable
public extension TokenDefinitionParticle {
    func hash(into hasher: inout Hasher) {
        hasher.combine(radixHash)
    }
}

// MARK: - From CreateTokenAction
public extension TokenDefinitionParticle {
    init(createTokenAction action: CreateTokenAction) {
        self.init(
            symbol: action.symbol,
            name: action.name,
            description: action.description,
            address: action.creator,
            granularity: action.granularity,
            permissions: action.supplyType.tokenPermissions
        )
    }
}
