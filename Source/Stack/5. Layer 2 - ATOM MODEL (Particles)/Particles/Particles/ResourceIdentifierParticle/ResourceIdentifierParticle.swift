//
//  ResourceIdentifierParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// A representation of something unique.
public struct ResourceIdentifierParticle:
    ParticleConvertible,
    RadixModelTypeStaticSpecifying,
    RadixCodable,
    Accountable
{
    // swiftlint:enable colon opening_brace

    public let resourceIdentifier: ResourceIdentifier
    
    /// This is in fact not really a `Nonce`, it is the only case where the value always should be zero.
    public let alwaysZeroNonce: Nonce = 0
    
    public init(
        resourceIdentifier: ResourceIdentifier
    ) {
        self.resourceIdentifier = resourceIdentifier
    }
    
}

// MARK: - From TokenDefinitionParticle
public extension ResourceIdentifierParticle {
    init(token: TokenDefinitionParticle) {
        self.init(resourceIdentifier: token.tokenDefinitionReference)
    }
}

// MARK: - Deodable
public extension ResourceIdentifierParticle {
    enum CodingKeys: String, CodingKey {
        case serializer
        case resourceIdentifier = "rri"
        case alwaysZeroNonce = "nonce"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        resourceIdentifier = try container.decode(ResourceIdentifier.self, forKey: .resourceIdentifier)
    }
}

// MARK: - Encodable
public extension ResourceIdentifierParticle {
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .alwaysZeroNonce, value: alwaysZeroNonce),
            EncodableKeyValue(key: .resourceIdentifier, value: resourceIdentifier)
        ]
    }
}

// MARK: - Accountable
public extension ResourceIdentifierParticle {
    var addresses: Addresses {
        return [resourceIdentifier.address]
    }
}

// MARK: - RadixModelTypeStaticSpecifying
public extension ResourceIdentifierParticle {
    static let serializer: RadixModelType = .resourceIdentifierParticle
}
