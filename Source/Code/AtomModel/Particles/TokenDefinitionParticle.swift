//
//  TokenDefinitionParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenDefinitionParticle: ParticleConvertible, Identifiable {
    
    public let type: ParticleTypes = .tokenDefinition
    
    public let symbol: Symbol
    public let name: Name
    public let description: Description
    public let address: Address
    public let metaData: MetaData
    public let granularity: Granularity
    public let permissions: TokenPermissions
    
    public init(
        symbol: Symbol,
        name: Name,
        description: Description,
        address: Address,
        metaData: MetaData = [:],
        granularity: Granularity,
        permissions: TokenPermissions
        ) {
        self.symbol = symbol
        self.name = name
        self.description = description
        self.address = address
        self.metaData = metaData
        self.granularity = granularity
        self.permissions = permissions
    }

}

// MARK: - Identifiable
public extension TokenDefinitionParticle {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: address, type: .tokens, symbol: symbol)
    }
}

// MARK: - Codable
public extension TokenDefinitionParticle {
    public enum CodingKeys: String, CodingKey {
        case type, symbol, name, description, address, metaData, granularity, permissions
    }
}

// MARK: - Decodable
public extension TokenDefinitionParticle {
 
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(Symbol.self, forKey: .symbol)
        name = try container.decode(Name.self, forKey: .name)
        description = try container.decode(Description.self, forKey: .description)
        address = try container.decode(Address.self, forKey: .address)
        metaData = try container.decode(MetaData.self, forKey: .metaData)
        granularity = try container.decode(Granularity.self, forKey: .granularity)
        permissions = try container.decode(TokenPermissions.self, forKey: .permissions)
    }
}
