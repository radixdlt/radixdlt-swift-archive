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
    
    public func keyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        var properties: [EncodableKeyValue<CodingKeys>]  = [
            EncodableKeyValue(key: .symbol, value: symbol),
            EncodableKeyValue(key: .description, value: description),
            EncodableKeyValue(key: .granularity, value: granularity),
            EncodableKeyValue(key: .permissions, value: permissions),
            EncodableKeyValue(key: .address, value: address),
            EncodableKeyValue(key: .name, value: name)
        ]
        if !metaData.isEmpty {
            properties.append(EncodableKeyValue(key: .metaData, value: metaData))
        }
        return properties
    }
}
