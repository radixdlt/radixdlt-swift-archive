//
//  TokenDefinitionParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenDefinitionParticle: ParticleConvertible, Identifiable {
    
    public let symbol: Symbol
    public let name: Name
    public let description: Description
    public let creator: Address
    public let metaData: MetaData
    public let granularity: Granularity
    public let permissions: TokenPermissions

}

// MARK: - Identifiable
public extension TokenDefinitionParticle {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: creator, type: .tokens, symbol: symbol)
    }
}

// MARK: - Codable
public extension TokenDefinitionParticle {
    public enum CodingKeys: CodingKey {
        case symbol, name, description, creator, metaData, granularity, permissions
    }
}

// MARK: - Decodable
public extension TokenDefinitionParticle {
 
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(Symbol.self, forKey: .symbol)
        name = try container.decode(Name.self, forKey: .name)
        description = try container.decode(Description.self, forKey: .description)
        creator = try container.decode(Address.self, forKey: .creator)
        metaData = try container.decode(MetaData.self, forKey: .metaData)
        granularity = try container.decode(Dson<Granularity>.self, forKey: .granularity).value
        permissions = try container.decode(TokenPermissions.self, forKey: .permissions)
    }
}
