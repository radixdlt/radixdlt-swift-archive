//
//  EncodableKeyValueListConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol EncodableKeyValueListConvertible: AnyEncodableKeyValueListConvertible {
    associatedtype CodingKeys: CodingKey
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>]
}

// MARK: - AnyEncodableKeyValueListConvertible
public extension EncodableKeyValueListConvertible {
    func anyEncodableKeyValues(output: DSONOutput) throws -> [AnyEncodableKeyValue] {
        return try encodableKeyValues().map { try $0.toAnyEncodableKeyValue() }
    }
}

// MARK: - Swift.Encodable (JSON)
public extension Encodable where Self: EncodableKeyValueListConvertible {
    func encode(to encoder: Encoder) throws {
        guard let serializerValueCodingKey = CodingKeys(stringValue: RadixModelType.jsonKey) else {
            incorrectImplementation("You MUST declare a CodingKey having the string value `\(RadixModelType.jsonKey)` in your encodable model.")
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let modelTypeSpecifying = self as? RadixModelTypeStaticSpecifying {
            try container.encode(modelTypeSpecifying.serializer, forKey: serializerValueCodingKey)
        }
        
        try encodableKeyValues().forEach {
            try $0.jsonEncoded(by: &container)
        }
    }
}
