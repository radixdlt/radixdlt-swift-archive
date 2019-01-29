//
//  TokenParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenParticle: ParticleConvertible, CustomStringConvertible {
    public let quarks: Quarks
    
    public let name: String
    public let description: String
    public let granularity: Granularity
    public let iconData: Data?
    public let permissions: TokenPermissions
    
    public init(
        address: Address,
        name: String,
        symbol: String,
        description: String,
        granularity: Granularity,
        permissions: TokenPermissions = [:],
        icon: Data? = nil
        ) {
        self.quarks = [
            IdentifiableQuark(identifier: ResourceIdentifier(address: address, type: .tokenClass, unique: symbol)),
            AccountableQuark(address: address),
            OwnableQuark(owner: address.publicKey)
        ]
        self.name = name
        self.description = description
        self.granularity = granularity
        self.permissions = permissions
        self.iconData = icon
    }
}

// MARK: Decodable
public extension TokenParticle {
    public enum CodingKeys: String, CodingKey {
        case quarks, name, description, granularity, permissions
        case iconData = "icon"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quarks = try container.decode(Quarks.self, forKey: .quarks)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(Dson<String>.self, forKey: .description).value
        granularity = try container.decode(Dson<Granularity>.self, forKey: .granularity).value
        iconData = try container.decodeIfPresent(Data.self, forKey: .iconData)
        permissions = try container.decode(TokenPermissions.self, forKey: .permissions)
    }
}

// MARK: Encodable
public extension TokenParticle {
    func encode(to encoder: Encoder) throws {
        implementMe
    }
}

public extension TokenParticle {
    func tokenClassReference() throws -> TokenClassReference {
        return TokenClassReference(identifier: try quarkOrError(type: IdentifiableQuark.self).identifier)
    }
}
