//
//  TokenDefinitionParticle+Encodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-08.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - EncodableKeyValueListConvertible
public extension TokenDefinitionParticle {
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .symbol, value: symbol),
            EncodableKeyValue(key: .iconUrl, ifPresent: try? StringValue(string: iconUrl?.absoluteString)),
            EncodableKeyValue(key: .description, value: description),
            EncodableKeyValue(key: .granularity, value: granularity),
            EncodableKeyValue(key: .permissions, value: permissions),
            EncodableKeyValue(key: .address, value: address),
            EncodableKeyValue(key: .name, value: name)
        ].compactMap { $0 }
    }
}
