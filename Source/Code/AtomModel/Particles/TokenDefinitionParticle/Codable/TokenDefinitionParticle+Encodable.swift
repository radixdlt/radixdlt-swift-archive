//
//  TokenDefinitionParticle+Encodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-08.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Decodable
public extension TokenDefinitionParticle {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(address, forKey: .address)
        try container.encode(granularity, forKey: .granularity)
        try container.encode(metaData, forKey: .metaData)
        try container.encode(permissions, forKey: .permissions)
    }
}
