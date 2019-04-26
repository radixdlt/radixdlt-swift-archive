//
//  EncodableKeyValueListConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol EncodableKeyValueListConvertible {
    associatedtype CodingKeys: CodingKey
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>]
}

// MARK: - Swift.Encodable (JSON)
public extension Encodable where Self: EncodableKeyValueListConvertible {
    func encode(to encoder: Encoder) throws {
        guard let serializerValueCodingKey = CodingKeys(stringValue: RadixModelType.jsonKey) else {
            incorrectImplementation("You MUST declare a CodingKey having the string value `\(RadixModelType.jsonKey)` in your encodable model.")
        }
        
        guard let serializerVersionCodingKey = CodingKeys(stringValue: jsonKeyVersion) else {
            incorrectImplementation("You MUST declare a CodingKey having the string value `\(jsonKeyVersion)` in your encodable model.")
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serializerVersion, forKey: serializerVersionCodingKey)
        
        if let modelTypeSpecifying = self as? RadixModelTypeStaticSpecifying {
            try container.encode(modelTypeSpecifying.serializer, forKey: serializerValueCodingKey)
        }
        
        try encodableKeyValues().forEach {
            try $0.jsonEncoded(by: &container)
        }
    }
}
