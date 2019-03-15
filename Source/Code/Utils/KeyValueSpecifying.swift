//
//  KeyValueSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol KeyValueSpecifying: CBORPropertyListConvertible {
    associatedtype CodingKeys: CodingKey
    func keyValues() throws -> [EncodableKeyValue<CodingKeys>]
}

// MARK: - CBORPropertyListConvertible
public extension KeyValueSpecifying {
    func propertyList(output: DSONOutput) throws -> [CBOREncodableProperty] {
        return try keyValues().map { try $0.toCBOREncodableProperty() }
    }
}

// MARK: - Swift.Encodable (JSON)
public extension Encodable where Self: KeyValueSpecifying {
    func encode(to encoder: Encoder) throws {
        guard let typeKey = CodingKeys(stringValue: RadixModelType.jsonKey) else {
            incorrectImplementation("You MUST declare a CodingKey having the string value \(RadixModelType.jsonKey) in your encodable model.")
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let modelTypeSpecyfing = self as? RadixModelTypeSpecifying {
            try container.encode(modelTypeSpecyfing.type, forKey: typeKey)
        }
        
        try keyValues().forEach {
            try $0.jsonEncoded(by: &container)
        }
    }
}
